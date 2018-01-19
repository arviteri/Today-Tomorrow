//
//  NotificationInterval.swift
//  Simple Todo
//
//  Created by Andrew Viteri on 1/19/18.
//  Copyright © 2018 Andrew Viteri. All rights reserved.
//

import Foundation

class NotificationInterval {
    
    static let intervalTitles = ["Hourly", "Every Three Hours", "Every Six Hours", "Daily"]
    var title: String = ""
    var checked: Bool = false
    
    init(title: String, checked: Bool) {
        self.title = title
        self.checked = checked
    }
}
