//
//  ColorsViewController.swift
//  WeekTodo
//
//  Created by daniel on 2017. 3. 26..
//  Copyright © 2017년 daniel. All rights reserved.
//

import UIKit

class ColorsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let colors = listEnum(ListColor.self)
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 100
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cCell", for: indexPath) as! ColorTableViewCell
        let color = colors[indexPath.row]
        
        cell.label.text = color.rawValue
        cell.gradientLayer.colors = [color.get()[0].cgColor, color.get()[1].cgColor]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("haha")
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                let userDefaults = UserDefaults.standard
                userDefaults.set(self.colors[indexPath.row].rawValue, forKey: "color")
                NotificationCenter.default.post(name: Notification.Name("Color"), object: nil)
            }
        }
    }

}

class ColorTableViewCell: UITableViewCell {
    
    let gradientLayer = CAGradientLayer()
    let label = UILabel()
    let backView = UIView()
    
    override func awakeFromNib() {
        backView.layer.cornerRadius = 10
        backView.clipsToBounds = true
        addSubview(backView)
        constrain(backView) { backView in
            backView.left == backView.superview!.left + 4
            backView.top == backView.superview!.top + 4
            backView.bottom == backView.superview!.bottom - 4
            backView.right == backView.superview!.right - 4
        }
        
        backView.layer.addSublayer(gradientLayer)
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 22)
        backView.addSubview(label)
        constrain(label) { backView in
            backView.left == backView.superview!.left
            backView.top == backView.superview!.top
            backView.bottom == backView.superview!.bottom
            backView.right == backView.superview!.right
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
