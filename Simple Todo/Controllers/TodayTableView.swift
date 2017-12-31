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
    
    let realm = try! Realm() //OKAY. Checked Realm initiation in AppDelegate.swift
    var todoItems: Results<ToDoItem>?

    override func viewDidLoad() {
        super.viewDidLoad()
        removeCompletedData()
        loadItems()
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard let currentItem = todoItems?[indexPath.row] else {fatalError("FATAL: Error displaying tableview data.")}
        if currentItem.isMustDo { cell.textLabel?.textColor = UIColor.black } else {
            cell.textLabel?.textColor = UIColor.lightGray
        }
        if currentItem.completed {
            let attributedString = NSMutableAttributedString(string: currentItem.title)
            attributedString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(0, attributedString.length))
            cell.textLabel?.attributedText = attributedString
            cell.accessoryType = .checkmark
        } else {
            cell.textLabel?.attributedText = NSMutableAttributedString(string: currentItem.title)
            cell.accessoryType = .none
        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedItem = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    selectedItem.completed = !selectedItem.completed
                }
            } catch {
                print("Error upating ToDoItem attribute after selection: \(error)")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
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
        }
        
        let mustAction = createAction(title: "Must Do", textField: currentTextField, mustDo: true)
        let shouldAction = createAction(title: "Should Do", textField: currentTextField, mustDo: false)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(mustAction)
        alert.addAction(shouldAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = UIColor.black
        present(alert, animated: true, completion: nil)
    }
    
    //Create action depending on ToDo's isMustDo Variable
    func createAction(title: String, textField: UITextField, mustDo: Bool) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: .default) { (action) in
            if let textInput = textField.text {
                let itemToSave: ToDoItem = ToDoItem()
                itemToSave.title = textInput
                itemToSave.isMustDo = mustDo
                self.saveItem(item: itemToSave)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        return action
    }
    
    
    //MARK: - Realm Database Methods
    func saveItem(item: ToDoItem) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("Error saving ToDoItem to Realm Database: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems() {
        let endOfDay : [Int] = [23-Date().hour, 59-Date().minute, 59-Date().second]
        let tomorrow = (endOfDay[0].hours + endOfDay[1].minutes + endOfDay[2].seconds).fromNow()! as NSDate
        todoItems = realm.objects(ToDoItem.self).filter(NSPredicate(format: "date <= %@", tomorrow)).sorted(byKeyPath: "isMustDo", ascending: false)
        tableView.reloadData()
    }
    
    func deleteItem(at indexPath: IndexPath) {
        if let itemToDelete = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemToDelete)
                }
            } catch {
                print("Error deleting ToDoItem from Realm Database: \(error)")
            }
        }
        tableView.reloadData()
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
        let predicates = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "date < %@", today), NSPredicate(format: "completed == true")])
        itemsToDelete = realm.objects(ToDoItem.self).filter(predicates)
        deleteItems(items: itemsToDelete)
    }
    
}
