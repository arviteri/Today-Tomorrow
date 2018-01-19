//
//  NotificationToggleCell.swift
//  Simple Todo
//
//  Created by Andrew Viteri on 1/18/18.
//  Copyright © 2018 Andrew Viteri. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationToggleCell: UITableViewCell {

    @IBOutlet weak var toggle: UISwitch!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            toggle.isOn = true
        } else {
            toggle.isOn = false
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //TODO: - Complete Local Push Notification
    @IBAction func toggleSwitched(_ sender: UISwitch) {
        if sender.isOn == true {
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (didAllow, error) in
                    
                })
            } else {
                UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil))
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    

}
