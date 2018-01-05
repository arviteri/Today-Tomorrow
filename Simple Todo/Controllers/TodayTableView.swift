//
//  TodayTableView.swift
//  
//
//  Created by Andrew Viteri on 12/30/17.
//

import UIKit
import RealmSwift
import SwiftDate
import NotificationCenter

class TodayTableView: SwipeTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewBecameActive), name: .UIApplicationDidBecomeActive, object: nil)
        loadItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewBecameActive()
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
        super.loadItems(withPredicate: NSPredicate(format: "dateCreated <= %@", tomorrow))
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
    
    //Deletes Items which were created before today and are completed
    func removeCompletedData() {
        var itemsToDelete: Results<ToDoItem>?
        let startOfDay : [Int] = [-Date().hour, -Date().minute, -Date().second]
        let today = (startOfDay[0].hours + startOfDay[1].minutes + startOfDay[2].seconds).fromNow()! as NSDate
        itemsToDelete = realm.objects(ToDoItem.self).filter(NSPredicate(format: "dailyItem == false AND dateCreated < %@ AND completed == true", today))
        deleteItems(items: itemsToDelete)
    }
    
    //Used to keep items from previous days on list until end of the day. Without this method, old items will be removed after completed and tableView is reloaded
    func updateDates() {
        guard let itemList = todoItems else { fatalError("Error updating dates: guard let itemList = todoItems") }
        for item in itemList {
            do {
                try realm.write {
                    if item.dateCreated.isYesterday {
                        if item.dailyItem { item.completed = false }
                        item.dateCreated = Date()
                    }
                }
            } catch {
                print("Error updating ToDoItem date in Realm Database: \(error)")
            }
        }
    }
    
    
    
    //MARK: - View Methods
    @objc override func viewBecameActive() {
        removeCompletedData()
        loadItems()
        updateDates()
        tableView.reloadData()
    }
    
}
