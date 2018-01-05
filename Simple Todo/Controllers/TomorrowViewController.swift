//
//  TomorrowViewController.swift
//  Simple Todo
//
//  Created by Andrew Viteri on 12/30/17.
//  Copyright © 2017 Andrew Viteri. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftDate

class TomorrowViewController: SwipeTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    
    
    //MARK: - Bar Button IBActions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add A New Todo!", message: "", preferredStyle: .alert)
        var currentTextField = UITextField()
        alert.addTextField() { (textField) in
            currentTextField = textField
            currentTextField.placeholder = "What do you need to do?"
            currentTextField.textAlignment = .center
            currentTextField.autocapitalizationType = .words
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(createAction(title: "Must Do", textField: currentTextField, mustDo: true, daysAhead: 1))
        alert.addAction(createAction(title: "Should Do", textField: currentTextField, mustDo: false, daysAhead: 1))
        alert.addAction(cancelAction)
        alert.view.tintColor = UIColor.black
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Realm Database Methods
    func loadItems() {
        let endOfDay : [Int] = [23-Date().hour, 59-Date().minute, 59-Date().second]
        let tomorrow = (endOfDay[0].hours + endOfDay[1].minutes + endOfDay[2].seconds).fromNow()! as NSDate
        super.loadItems(withPredicate: NSPredicate(format: "dateCreated > %@", tomorrow))
    }
}
