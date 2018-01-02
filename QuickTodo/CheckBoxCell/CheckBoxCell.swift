//
//  CheckBoxCell.swift
//  QuickTodo
//
//  Created by Andrew Viteri on 1/1/18.
//  Copyright © 2018 Andrew Viteri. All rights reserved.
//

import UIKit
import BEMCheckBox

class CheckBoxCell: UITableViewCell {

    @IBOutlet weak var checkBoxView: BEMCheckBox!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkBoxView.onAnimationType = .fill
        checkBoxView.offAnimationType = .fill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
