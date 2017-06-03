//
//  ViewController.swift
//  WeekTodo
//
//  Created by daniel on 2017. 3. 16..
//  Copyright © 2017년 daniel. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TableViewCellDelegate {
    
    var index: Day!
    var todo: List<Todo>!
    var notificationToken: NotificationToken!
    let realm = try! Realm()
    let oneWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hideView: UIImageView!
    var segment: UISegmentedControl!
    let headerView = UIView()
    let headerLabel = UILabel()
    
    var colors: ListColor = .Default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        index = Day(rawValue: Date().getDay() - 1)
        
        segment = UISegmentedControl()
        segment.tintColor = .white
        segment.addTarget(self, action: #selector(change), for: .valueChanged)
        oneWeek.forEach {
            self.segment.insertSegment(withTitle: $0, at: self.oneWeek.index(of: $0)!, animated: false)
        }
        
        segment.selectedSegmentIndex = index.rawValue
        
        let userDefaults = UserDefaults.standard
        
        if let raw = userDefaults.string(forKey: "color") {
            colors = ListColor(rawValue: raw)!
        } else {
            userDefaults.set("Default", forKey: "color")
        }
        
        hideView.isHidden = true
        hideView.image = UIImage(named: "pull")?.withRenderingMode(.alwaysTemplate)
        hideView.tintColor = .white
        hideView.alpha = 0.4
        
        tableView.reorder.delegate = self
        tableView.reorder.cellScale = 1.05
        tableView.reorder.shadowOpacity = 0.5
        tableView.reorder.shadowRadius = 20
        tableView.reorder.shadowOffset = CGSize(width: 0, height: 10)
        tableView.reorder.cellOpacity = 0.95
        
        if realm.isEmpty {
            print("some")
            try! realm.write {
                let new = Weak()
                realm.add(new)
            }
        }
        
        load()
        
        self.notificationToken = self.realm.addNotificationBlock { _ in
            DispatchQueue.main.async {
                self.load()
            }
        }
        
        let center = UNUserNotificationCenter.current()
        
        center.getPendingNotificationRequests {
            for i in $0 {
                print("\(i.content.body):\nid = \(i.identifier)\ndate = \(i.trigger)\n\n")
            }
        }
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.showsVerticalScrollIndicator = false
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellDidClicked)))
        NotificationCenter.default.addObserver(self, selector: #selector(reloadColor), name: Notification.Name("Color"), object: nil)
        
        setupHeaderView()
        updateHeaderView()
    }
    
    func setupHeaderView() {
        headerView.backgroundColor = .clear
        tableView.addSubview(headerView)
        
        headerLabel.font = .systemFont(ofSize: 18)
        headerLabel.textColor = .white
        headerLabel.alpha = 0
        headerLabel.text = "Pull down to Add"
        headerView.addSubview(headerLabel)
        constrain(headerLabel) { label in
            label.left == label.superview!.left + 12
            label.top == label.superview!.top
            label.bottom == label.superview!.bottom
            label.right == label.superview!.right - 12
        }

    }
    
    func reloadColor() {
        let userDefaults = UserDefaults.standard
        
        if let raw = userDefaults.string(forKey: "color") {
            colors = ListColor(rawValue: raw)!
        } else {
            userDefaults.set("Default", forKey: "color")
        }
        
        tableView.reloadData()
    }
    
    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0)
        if tableView.contentOffset.y < 0 {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        
        if tableView.contentOffset.y > -80 {
            headerLabel.text = "Pull down to Add"
            headerLabel.textColor = .white
        } else if tableView.contentOffset.y <= -50 && tableView.contentOffset.y > -150 {
            headerLabel.text = "Release to Add"
            headerLabel.textColor = .white
        } else if tableView.contentOffset.y <= -150 {
            headerLabel.text = "Pull down to Change Theme"
            headerLabel.textColor = colorForIndex(0)
        }
        
        let float = CGFloat(min(1, Double(abs(tableView.contentOffset.y) / 80)))
        headerLabel.alpha = float
        
        headerView.frame = headerRect
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        updateHeaderView()
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y <= -80 && scrollView.contentOffset.y > -150 {
            
            add()
        } else if scrollView.contentOffset.y <= -150 {
            
            let st = UIStoryboard(name: "Main", bundle: nil)
            let viewCon = st.instantiateViewController(withIdentifier: "colorsView") as! ColorsViewController
            self.present(viewCon, animated: true, completion: nil)
        }
    }
    
    func load() {
        if let objects = realm.objects(Weak.self).first {
            todo = objects.get(index)
        }
        
        tableView.reloadData()
        print("hello")
        
    }
    
    func add() {
        
        let alertController = UIAlertController(title: "새로운 할 일", message: "해야 할 일을 쓰세요", preferredStyle: .alert)
        var alertTextField: UITextField!
        alertController.addTextField { textField in
            alertTextField = textField
            textField.placeholder = "write anything..."
        }
        alertController.addAction(UIAlertAction(title: "추가하기", style: .default) { _ in
            guard let text = alertTextField.text , !text.isEmpty else { return }
            
            let some = Todo()
            some.text = text
            
            self.realm.beginWrite()
            self.todo.insert(some, at: 0)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            self.finishUIWrite()
        })
        
        alertController.addAction(UIAlertAction(title: "알림과 함께 추가하기", style: .default) { _ in
            guard let text = alertTextField.text , !text.isEmpty else { return }
            
            let some = Todo()
            some.text = text
            
            let date = Date()
            some.id = date as NSDate?
            
            self.realm.beginWrite()
            self.todo.insert(some, at: 0)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            self.finishUIWrite()
            
            self.showDate(text, date, some)
        })
       
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func showDate(_ text: String, _ date: Date, _ item: Todo) {
        DatePickerDialog(showCancelButton: false).show("Select time", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .time) {
            
            
            
            let fire = $0!
            let nDate = Calendar.current.dateComponents([.hour, .minute], from: fire)
            
            let trigDate = DateComponents(calendar: Calendar.current, hour: nDate.hour, minute: nDate.minute, weekday: self.index.rawValue + 1)
            //let trigDate = Calendar.current.dateComponents([.weekday,.hour,.minute], from: fire)
            
            let trig = UNCalendarNotificationTrigger(dateMatching: trigDate, repeats: true)
            let content = UNMutableNotificationContent()
            content.title = "You have to do Something!"
            content.body = text
            content.sound = UNNotificationSound.default()
            
            let noti = UNNotificationRequest(identifier: "\(date)", content: content, trigger: trig)
            
            let center = UNUserNotificationCenter.current()
            center.add(noti, withCompletionHandler: nil)
            
            try! self.realm.write {
                item.fireDate = fire as NSDate?
            }
            
        }
    }
    
    func change(_ sender: UISegmentedControl) {
        index = Day(rawValue: sender.selectedSegmentIndex)!
        load()
        if !todo.isEmpty {
            hideView.isHidden = true
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        } else {
            hideView.isHidden = false
        }
    }
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        hideView.isHidden = todo.count != 0
        return todo.count
    }
    
    
 
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return makeView("할 일")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 51
    }
    
    func makeView(_ text: String) -> UIView {
        let headerView = UIVisualEffectView()
        let blur = UIBlurEffect(style: .dark)
        headerView.effect = blur
        
        /*
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        label.text = text
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 15)
        */
        headerView.addSubview(segment)
        constrain(segment) { seg in
            seg.left == seg.superview!.left + 8
            seg.top == seg.superview!.top + 11
            seg.bottom == seg.superview!.bottom - 11
            seg.right == seg.superview!.right - 8
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TodoTableViewCells
        
        cell.todo = todo[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let tCell = cell as? TodoTableViewCells {
            tCell.backView.backgroundColor = colorForIndex(indexPath.row)
        }
        
    }
    
    func colorForIndex(_ index: Int) -> UIColor {
        let fraction = Double(index) / Double(max(13, todo.count))
        return colors.get().gradientColor(atFraction: fraction)
    }

    func itemDeleted(_ todoItem: Todo) {
        
        if let id = todoItem.id as? Date {
            let center = UNUserNotificationCenter.current()
            center.getPendingNotificationRequests {
                for i in $0 {
                    if i.identifier == "\(id)" {
                        print(i)
                        center.removePendingNotificationRequests(withIdentifiers: [i.identifier])
                        break
                    }
                }
            }
        }
        
        uiWrite {
            
            guard let i = todo.index(of: todoItem) else {
                return
            }
            
            realm.delete(todoItem)
            tableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .left)
            hideView.isHidden = todo.count != 0
        }
        
    }
    
    func itemCompleted(_ todoItem: Todo) {
        
        if let id = todoItem.id as? Date {
            let center = UNUserNotificationCenter.current()
            center.getPendingNotificationRequests {
                for i in $0 {
                    if i.identifier == "\(id)" {
                        print(i)
                        center.removePendingNotificationRequests(withIdentifiers: [i.identifier])
                        break
                    }
                }
            }
        }
        
        
        uiWrite {
            
            guard let i = todo.index(of: todoItem) else {
                return
            }
            
            let sourceIndexPath = IndexPath(row: i, section: 0)
            let destinationIndexPath: IndexPath
            
            todoItem.completed = !todoItem.completed
            
            if !todoItem.completed {
                
                if let date = todoItem.fireDate as? Date {
                    let dates = Date()
                    todoItem.id = dates as NSDate?
                    
                    let nDate = Calendar.current.dateComponents([.hour, .minute], from: date)
                    
                    let trigDate = DateComponents(calendar: Calendar.current, hour: nDate.hour, minute: nDate.minute, weekday: self.index.rawValue + 1)
                    
                    //let trigDate = Calendar.current.dateComponents([.weekday,.hour,.minute], from: date)
                    
                    let trig = UNCalendarNotificationTrigger(dateMatching: trigDate, repeats: true)
                    let content = UNMutableNotificationContent()
                    content.title = "You have to do Something!"
                    content.body = todoItem.text
                    content.sound = UNNotificationSound.default()
                    
                    let noti = UNNotificationRequest(identifier: "\(dates)", content: content, trigger: trig)
                    
                    let center = UNUserNotificationCenter.current()
                    center.add(noti, withCompletionHandler: nil)
                }
                
                destinationIndexPath = IndexPath(row: todo.count - todo.filter("completed = true").count - 1, section: 0)
                
            } else {
                
                todoItem.id = nil
                
                destinationIndexPath = IndexPath(row: todo.count - 1, section: 0)
                
            }
            
            self.todo.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
            self.tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
        }
    }
    
    func cellDidClicked(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath) as? TodoTableViewCells,
            let todoItem = cell.todo else { return }
       
        
        guard !todoItem.completed else {
            return
        }

        let alertController = UIAlertController(title: "할 일 변경하기", message: "해야 할 일을 쓰세요", preferredStyle: .alert)
        var alertTextField: UITextField!
        
        alertController.addTextField { textField in
            alertTextField = textField
            textField.placeholder = "write anything..."
            textField.text = todoItem.text
        }
        alertController.addAction(UIAlertAction(title: "변경하기", style: .default) { _ in
            guard let text = alertTextField.text , !text.isEmpty else { return }
            
            try! self.realm.write {
                todoItem.text = text
            }
        })
        
        if let id = todoItem.id as? Date {
            
            alertController.addAction(UIAlertAction(title: "알림시간 변경하기", style: .default) { _ in
                guard let text = alertTextField.text , !text.isEmpty else { return }
                
                let center = UNUserNotificationCenter.current()
                
                try! self.realm.write {
                    todoItem.text = text
                    
                    center.getPendingNotificationRequests {
                        for i in $0 {
                            if i.identifier == "\(id)" {
                                print(i)
                                center.removePendingNotificationRequests(withIdentifiers: [i.identifier])
                                break
                            }
                        }
                    }
                    
                    self.showDate(text, id, todoItem)
                    
                }
                
            })
            
            alertController.addAction(UIAlertAction(title: "알림 끄기", style: .destructive) { _ in
                guard let text = alertTextField.text , !text.isEmpty else { return }
                
                let center = UNUserNotificationCenter.current()
                
                center.getPendingNotificationRequests {
                    for i in $0 {
                        if i.identifier == "\(id)" {
                            print("\(i.content.body):\nid = \(i.identifier)\ndate = \(i.trigger)\n\n")
                            center.removePendingNotificationRequests(withIdentifiers: [i.identifier])
                            break
                        }
                    }
                }
                
                self.uiWriteNoUpdateList {
                    
                    todoItem.text = text
                    todoItem.id = nil
                    todoItem.fireDate = nil
                    print("write")
                    self.didUpdateList(reload: true)
                }
                
            
                
            })
            
        } else {
            
            alertController.addAction(UIAlertAction(title: "알림 추가하기", style: .default) { _ in
                guard let text = alertTextField.text , !text.isEmpty else { return }
                
                let date = Date()
                
                try! self.realm.write {
                    todoItem.text = text
                    todoItem.id = date as NSDate?
                }
                
                self.showDate(text, date, todoItem)
            })
        }
        
        
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alertController, animated: true, completion: nil)
    }
    
   
    
    func reorder(_ sourceIndexPath: IndexPath, _ destinationIndexPath: IndexPath) {
        todo.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func updateColors(completion: (() -> Void)? = nil) {
        
        let visibleCellsAndColors = tableView.visibleCells.map { cell in
            return (cell, colorForIndex(tableView.indexPath(for: cell)!.row))
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            for (cell, color) in visibleCellsAndColors {
                if let tCell = cell as? TodoTableViewCells {
                    tCell.backView.backgroundColor = color
                }
            }
        }, completion: { _ in
            completion?()
        })
    }
    
    func uiWrite(block: () -> Void) {
        uiWriteNoUpdateList(block: block)
        didUpdateList(reload: false)
    }
    
    func uiWriteNoUpdateList(block: () -> Void) {
        realm.beginWrite()
        block()
        commitUIWrite()
    }
    
    func finishUIWrite() {
        commitUIWrite()
        didUpdateList(reload: false)
    }
    
    private func commitUIWrite() {
        _ = try? realm.commitWrite(withoutNotifying: [notificationToken!])
    }
    
    func didUpdateList(reload: Bool) {
        
        updateColors()
        if reload {
            load()
            print("loadEND")
        }
    }
    
}

extension ViewController: TableViewReorderDelegate {
    
    func tableViewDidBeginReordering(_ tableView: UITableView) {
        UIView.animate(withDuration: 0.3) {
            self.segment.isEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        uiWriteNoUpdateList {
            self.reorder(sourceIndexPath, destinationIndexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool {
        let cell = tableView.cellForRow(at: indexPath) as! TodoTableViewCells
        return !cell.todo.completed
    }
    
    func tableViewDidFinishReordering(_ tableView: UITableView) {
        didUpdateList(reload: false)
        UIView.animate(withDuration: 0.3) {
            self.segment.isEnabled = true
        }
    }
    
}
