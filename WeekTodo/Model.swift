//
//  Model.swift
//  WeekTodo
//
//  Created by daniel on 2017. 3. 16..
//  Copyright © 2017년 daniel. All rights reserved.
//

import RealmSwift
import Foundation

enum Day: Int {
    case sun = 0
    case mon = 1
    case tue = 2
    case wed = 3
    case thu = 4
    case fri = 5
    case sat = 6
}

class Weak: Object {
    
    let mon = List<Todo>()
    let tue = List<Todo>()
    let wed = List<Todo>()
    let thu = List<Todo>()
    let fri = List<Todo>()
    let sat = List<Todo>()
    let sun = List<Todo>()
    
    func get(_ day: Day) -> List<Todo> {
        switch day {
        case .sun:
            return sun
        case .mon:
            return mon
        case .tue:
            return tue
        case .wed:
            return wed
        case .thu:
            return thu
        case .fri:
            return fri
        case .sat:
            return sat
        }
    }
    
}

class Todo: Object {
    dynamic var text = ""
    dynamic var completed = false
    dynamic var id: NSDate? = nil
    dynamic var fireDate: NSDate? = nil
}
