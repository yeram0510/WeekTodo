//
//  NoteDetailTableViewCell.swift
//  Notey
//
//  Created by daniel on 2016. 3. 18..
//  Copyright © 2016년 daniel. All rights reserved.
//

import UIKit
import AudioToolbox

protocol TableViewCellDelegate {
    
    func itemDeleted(_ todoItem: Todo)
    func itemCompleted(_ todoItem: Todo)
}

private enum ReleaseAction {
    case Complete, Delete
}

func vibrate() {
    let isDevice = { return TARGET_OS_SIMULATOR == 0 }()
    if isDevice {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}


class TodoTableViewCells: UITableViewCell {
    
    var todo: Todo! {
        didSet {
            if let date = todo.fireDate as? Date {
                TextView.attributedText = setDate(date)
            } else {
                TextView.text = todo.text
            }
            setCompleted(todo.completed)
        }
    }
   
    let itemCompleteLayer = UIView()
    
    private var releaseAction: ReleaseAction?
    
    var delegate: TableViewCellDelegate?

    var TextView = UILabel()
    var backView = UIView()
    
    private let doneIconView = UIImageView(image: UIImage(named: "done")!.withRenderingMode(.alwaysTemplate))
    private let deleteIconView = UIImageView(image: UIImage(named: "delete")!.withRenderingMode(.alwaysTemplate))
    private var originalDoneIconCenter = CGPoint()
    private var originalDeleteIconCenter = CGPoint()
    private let iconWidth: CGFloat = 60
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupIconViews()
        setupMainView()
        setupCompleteLayer()
        setupTextView()
        setupBorders()
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
        
    }
    
    private func setupIconViews() {
        doneIconView.center = center
        doneIconView.frame.origin.x = 20
        doneIconView.alpha = 0
        doneIconView.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        insertSubview(doneIconView, belowSubview: contentView)
        
        deleteIconView.center = center
        deleteIconView.frame.origin.x = bounds.width - deleteIconView.bounds.width - 20
        deleteIconView.alpha = 0
        deleteIconView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
        insertSubview(deleteIconView, belowSubview: contentView)
    }
    
    private func setupMainView() {
        selectionStyle = .none
        contentView.backgroundColor = .black
        backgroundColor = .black
        
        contentView.addSubview(backView)
        
        constrain(backView) { backView in
            backView.left == backView.superview!.left
            backView.top == backView.superview!.top
            backView.bottom == backView.superview!.bottom
            backView.right == backView.superview!.right
        }
    }
    
    private func setupCompleteLayer() {
        itemCompleteLayer.backgroundColor = .completeDimBackground
        itemCompleteLayer.isHidden = true
        
        backView.addSubview(itemCompleteLayer)
        
        constrain(itemCompleteLayer) { backgroundOverlayView in
            backgroundOverlayView.edges == backgroundOverlayView.superview!.edges
        }
    }
    
    private func setupTextView() {
        TextView.textColor = .white
        TextView.font = .systemFont(ofSize: 18)
        TextView.backgroundColor = .clear
        TextView.alpha = 1
        TextView.numberOfLines = 0
        
        backView.addSubview(TextView)
        
        constrain(TextView) { textView in
            textView.left == textView.superview!.left + 12
            textView.top == textView.superview!.top + 16
            textView.bottom == textView.superview!.bottom - 16
            textView.right == textView.superview!.right - 12
        }
    }
    
    private func setupBorders() {
        let singlePixelInPoints = 1 / UIScreen.main.scale
        
        let highlightLine = UIView()
        highlightLine.backgroundColor = UIColor(white: 1, alpha: 0.05)
        addSubview(highlightLine)
        constrain(highlightLine) { highlightLine in
            highlightLine.top == highlightLine.superview!.top
            highlightLine.left == highlightLine.superview!.left
            highlightLine.right == highlightLine.superview!.right
            highlightLine.height == singlePixelInPoints
        }
        
        let shadowLine = UIView()
        shadowLine.backgroundColor = UIColor(white: 0, alpha: 0.05)
        addSubview(shadowLine)
        constrain(shadowLine) { shadowLine in
            shadowLine.bottom == shadowLine.superview!.bottom
            shadowLine.left == shadowLine.superview!.left
            shadowLine.right == shadowLine.superview!.right
            shadowLine.height == singlePixelInPoints
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        itemCompleteLayer.frame = bounds
    }
    
    //MARK: - horizontal pan gesture methods
    
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
        case .began:
            originalDeleteIconCenter = deleteIconView.center
            originalDoneIconCenter = doneIconView.center
            
            releaseAction = nil
        case .changed:
            let translation = recognizer.translation(in: self)
           
            let x: CGFloat
            // Slow down translation
            if translation.x < 0 {
                x = translation.x / 2
                if x < -iconWidth {
                    deleteIconView.center = CGPoint(x: originalDeleteIconCenter.x + iconWidth + x, y: originalDeleteIconCenter.y)
                }
            } else if translation.x > iconWidth {
                let offset = (translation.x - iconWidth) / 3
                doneIconView.center = CGPoint(x: originalDoneIconCenter.x + offset, y: originalDoneIconCenter.y)
                x = iconWidth + offset
            } else {
                x = translation.x
            }
            
            contentView.frame.origin.x = x
            
            let fractionOfThreshold = min(1, Double(abs(x) / iconWidth))
            releaseAction = fractionOfThreshold >= 1 ? (x > 0 ? .Complete : .Delete) : nil
            //let float = min(1, Double(abs(x) / iconWidth))
            if x > 0 {
                doneIconView.alpha = CGFloat(fractionOfThreshold)
            } else {
                deleteIconView.alpha = CGFloat(fractionOfThreshold)
                //deleteIconView.transform = CGAffineTransform(scaleX: CGFloat(float), y: CGFloat(float))
            }

            doneIconView.tintColor = releaseAction == .Complete ? UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0) : .white
            deleteIconView.tintColor = releaseAction == .Delete ? .red : .white
            
            if !todo.completed {
                itemCompleteLayer.backgroundColor = .completeBackground
                itemCompleteLayer.isHidden = releaseAction != .Complete
                
                if contentView.frame.origin.x > 0 {
                    TextView.strike(fraction: fractionOfThreshold)
                } else {
                    releaseAction == .Complete ? TextView.strike() : TextView.unstrike()
                }
                
            } else {
                itemCompleteLayer.isHidden = releaseAction == .Complete
                TextView.alpha = releaseAction == .Complete ? 1 : 0.3
                
                if contentView.frame.origin.x > 0 {
                    TextView.strike(fraction: 1 - fractionOfThreshold)
                } else {
                    releaseAction == .Complete ? TextView.unstrike() : TextView.strike()
                }
            }
            
        case .ended:
            let animationBlock: () -> ()
            
            // If not deleting, slide it back into the middle
            // If we are deleting, slide it all the way out of the view
            switch releaseAction {
            case .Complete?:
                
                animationBlock = {
                    self.contentView.frame.origin.x = 0
                }
                
                UIView.animate(withDuration: 0.2, animations: animationBlock, completion: { _ in
                    
                    self.setCompleted(!self.todo.completed, animated: true)
                    
                    /*
                    self.itemCompleteLayer.isHidden = !self.todo.completed
                    self.itemCompleteLayer.backgroundColor = .completeDimBackground
                    self.TextView.alpha = self.todo.completed ? 0.3 : 1
                    */
                    self.doneIconView.frame.origin.x = 20
                    self.doneIconView.alpha = 0
                    
                    self.deleteIconView.frame.origin.x = self.bounds.width - self.deleteIconView.bounds.width - 20
                    self.deleteIconView.alpha = 0
                })
            case .Delete?:
                animationBlock = {
                    self.alpha = 0
                    self.contentView.alpha = 0
                    
                    self.contentView.frame.origin.x = -self.contentView.bounds.width - self.iconWidth
                    self.deleteIconView.frame.origin.x = -self.iconWidth + self.deleteIconView.bounds.width + 20
                    
                }
                
                UIView.animate(withDuration: 0.2, animations: animationBlock, completion: { _ in
                    vibrate()
                    self.delegate!.itemDeleted(self.todo)
                    self.doneIconView.frame.origin.x = 20
                    self.doneIconView.alpha = 0
                    
                    self.deleteIconView.frame.origin.x = self.bounds.width - self.deleteIconView.bounds.width - 20
                    self.deleteIconView.alpha = 0
                })
            case nil:
                
                self.todo.completed ? self.TextView.strike() : self.TextView.unstrike()
                
                animationBlock = {
                    print("nil")
                    self.contentView.frame.origin.x = 0
                    //self.itemCompleteLayer.isHidden = !self.todo.completed
                    //self.itemCompleteLayer.backgroundColor = self.todo.completed ? .completeDimBackground : .completeBackground
                }
                
                UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.allowUserInteraction, animations: animationBlock) { _ in
                    
                    self.doneIconView.frame.origin.x = 20
                    self.doneIconView.alpha = 0
                    
                    self.deleteIconView.frame.origin.x = self.bounds.width - self.deleteIconView.bounds.width - 20
                    self.deleteIconView.alpha = 0
                    
                }
            }
            
        default:
            break
        }
        
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        let translation = panGestureRecognizer.translation(in: superview!)
        return fabs(translation.x) > fabs(translation.y)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //print("prepare")
        self.alpha = 1
        self.contentView.alpha = 1
        TextView.unstrike()
        
    }
    
    func setDate(_ date: Date) -> NSAttributedString {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        
        let attrs = NSMutableAttributedString(string: todo.text)
        
        let timeAttrs = NSMutableAttributedString(string: "\n\(dateFormatter.string(from: date))", attributes: [
            NSFontAttributeName: UIFont.systemFont(ofSize: 12),
            NSForegroundColorAttributeName: UIColor("#f6f6f6")
            ])
        attrs.append(timeAttrs)
        
        return attrs
    }
    
    private func setCompleted(_ completed: Bool, animated: Bool = false) {
        completed ? TextView.strike() : TextView.unstrike()
        itemCompleteLayer.isHidden = !completed
        let updateColor = { [unowned self] in
            self.itemCompleteLayer.backgroundColor = completed ? .completeDimBackground : .completeBackground
            self.TextView.alpha = completed ? 0.3 : 1
        }
        if animated {
            //vibrate()
            UIView.animate(withDuration: 0.2, animations: updateColor)
            self.delegate!.itemCompleted(self.todo)
        } else {
            updateColor()
        }
    }
    
   
}

extension UILabel {
    
    func strike(fraction: Double = 1) {
        attributedText = attributedText?.strikedAttributedString(fraction: fraction)
    }
    
    func unstrike() {
        attributedText = attributedText?.unstrikedAttributedString
    }
}

extension NSAttributedString {
    
    func strikedAttributedString(fraction: Double = 1) -> NSAttributedString {
        let range = NSRange(0..<Int(fraction * Double(length)))
        return strike(with: .styleThick, range: range)
    }
    
    var unstrikedAttributedString: NSAttributedString {
        return strike(with: .styleNone)
    }
    
    private func strike(with style: NSUnderlineStyle, range: NSRange? = nil) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: self)
        let attributeName = NSStrikethroughStyleAttributeName
        let fullRange = NSRange(0..<length)
        
        mutableAttributedString.removeAttribute(attributeName, range: NSRange(location: 0, length: fullRange.length))
        mutableAttributedString.addAttribute(attributeName, value: style.rawValue, range: range ?? fullRange)
        return mutableAttributedString
    }
    
}
