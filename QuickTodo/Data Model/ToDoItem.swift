//
//  ToDoItem.swift
//  QuickTodo
//
//  Created by Andrew Viteri on 12/31/17.
//  Copyright © 2017 Andrew Viteri. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftDate

class ToDoItem: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var dateCreated: Date = Date()
    @objc dynamic var dateCompleted: Date?
    @objc dynamic var isMustDo: Bool = false
    @objc dynamic var dailyItem: Bool = false
    @objc dynamic var completed: Bool = false
    
}
