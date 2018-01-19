//
//  NotificationToggleCell.swift
//  Simple Todo
//
//  Created by Andrew Viteri on 1/18/18.
//  Copyright © 2018 Andrew Viteri. All rights reserved.
//

import UIKit

class NotificationToggleCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
     
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
