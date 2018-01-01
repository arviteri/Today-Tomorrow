//
//  TodayTableView.swift
//  
//
//  Created by Andrew Viteri on 12/30/17.
//

import UIKit
import RealmSwift
import SwiftDate

class TodayTableView: SwipeTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeCompletedData()
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        removeCompletedData()
    }
    
    
    //MARK: - Bar Button IBActions
    @IBAction func dayButtonPressed(_ sender: UIBarButtonItem) {
        if sender.tag == 0 {
            performSegue(withIdentifier: "goToTomorrow", sender: self)
        }
    }
    
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
        alert.addAction(createAction(title: "Must Do", textField: currentTextField, mustDo: true))
        alert.addAction(createAction(title: "Should Do", textField: currentTextField, mustDo: false))
        alert.addAction(cancelAction)
        alert.view.tintColor = UIColor.black
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Realm Database Methods
    func loadItems() {
        let endOfDay : [Int] = [23-Date().hour, 59-Date().minute, 59-Date().second]
        let tomorrow = (endOfDay[0].hours + endOfDay[1].minutes + endOfDay[2].seconds).fromNow()! as NSDate
        super.loadItems(withPredicate: NSPredicate(format: "dateCreated <= %@ OR dailyItem == true", tomorrow))
    }
    
    func deleteItems(items: Results<ToDoItem>?) {
        do {
            try realm.write {
                realm.delete(items!)
            }
        } catch {
            print("Error deleting multiple ToDoItems from Realm Database: \(error)")
        }
    }
    
    func removeCompletedData() {
        var itemsToDelete: Results<ToDoItem>?
        let startOfDay : [Int] = [-Date().hour, -Date().minute, -Date().second]
        let today = (startOfDay[0].hours + startOfDay[1].minutes + startOfDay[2].seconds).fromNow()! as NSDate
        let predicates = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "dateCreated < %@", today), NSPredicate(format: "completed == true"), NSPredicate(format: "dailyItem == false")])
        itemsToDelete = realm.objects(ToDoItem.self).filter(predicates)
        deleteItems(items: itemsToDelete)
        tableView.reloadData()
    }
    
}
