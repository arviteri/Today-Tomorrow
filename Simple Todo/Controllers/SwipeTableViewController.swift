//
//  SwipeTableViewController.swift
//  Simple Todo
//
//  Created by Andrew Viteri on 12/30/17.
//  Copyright © 2017 Andrew Viteri. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import NotificationCenter

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    var todoItems: Results<ToDoItem>?
    let realm = try! Realm(configuration: Realm.Configuration(fileURL: FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: "group.todo.data")!
        .appendingPathComponent("default.realm"))) //OKAY. Checked Realm initiation in AppDelegate.swift
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.becameActive), name: .UIApplicationDidBecomeActive, object: nil)
        tableView.rowHeight = 80
    }

    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        guard let currentItem = todoItems?[indexPath.row] else {fatalError("FATAL: Error displaying tableview data.")}
        if currentItem.isMustDo { cell.textLabel?.textColor = UIColor.black } else {
            cell.textLabel?.textColor = UIColor.darkGray
        }
        
        let todoTitle = currentItem.dailyItem ? "• " + currentItem.title : currentItem.title
        
        if currentItem.completed {
            let attributedString = NSMutableAttributedString(string: todoTitle)
            if currentItem.dailyItem {
                 attributedString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(2, attributedString.length-2))
            } else {
                 attributedString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(0, attributedString.length))
            }
            cell.textLabel?.attributedText = attributedString
            cell.accessoryType = .checkmark
            
        } else {
            cell.textLabel?.attributedText = NSMutableAttributedString(string: todoTitle)
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
                    selectedItem.dateCompleted = Date()
                }
            } catch {
                print("Error upating ToDoItem attribute after selection: \(error)")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }

    
    
    //MARK: - SwipeTableViewCell Delegate Methods
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        guard let currentItem = todoItems?[indexPath.row] else { fatalError("Error creating SwipeTableViewCell actions.") }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.deleteItem(at: indexPath)
        }
        
        let markDailyTitle = currentItem.dailyItem ? "Unmark Daily Item" : "Mark Daily Item"
        let markDailyAction = SwipeAction(style: .default, title: markDailyTitle) { (action, indexPath) in
            do {
                try self.realm.write {
                    currentItem.dailyItem = !currentItem.dailyItem
                }
            } catch {
                print("Error modifying ToDoItem attribute in Realm Database: \(error)")
            }
            (tableView.cellForRow(at: indexPath) as! SwipeTableViewCell).hideSwipe(animated: true)
            let deadlineTime = DispatchTime.now() + 0.5 //Used to wait for animation to complete
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                tableView.reloadData()
            }
        }
        deleteAction.image = UIImage(named: "Trash")
        markDailyAction.image = UIImage(named: "Calendar")
        return [deleteAction, markDailyAction]
    }
    
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .drag
        return options
    }
    
    
    
    //MARK: - UIAlert Action Creation Function
    func createAction(title: String, textField: UITextField, mustDo: Bool, daysAhead: Int = 0) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: .default) { (action) in
            if let textInput = textField.text {
                let itemToSave: ToDoItem = ToDoItem()
                itemToSave.title = textInput
                itemToSave.isMustDo = mustDo
                itemToSave.dateCreated = (daysAhead.days).fromNow()!
                self.saveItem(item: itemToSave)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        return action
    }
    
    
    
    //MARK: - Observer Methods
    @objc func becameActive() {
        tableView.reloadData()
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
    
    func loadItems(withPredicate predicate:NSPredicate) {
        todoItems = realm.objects(ToDoItem.self).filter(predicate).sorted(byKeyPath: "dailyItem", ascending: false).sorted(byKeyPath: "isMustDo", ascending: false)
        do {
            try realm.write {
                for item in todoItems! {
                    if let isYesterday = item.dateCompleted?.isYesterday {
                        if isYesterday && item.isMustDo {
                            item.completed = false
                        }
                    }
                }
            }
        } catch {
            
        }
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
    }

}
