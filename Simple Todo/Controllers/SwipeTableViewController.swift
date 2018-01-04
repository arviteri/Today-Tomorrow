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
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewBecameActive), name: .UIApplicationDidBecomeActive, object: nil)
        tableView.rowHeight = 80
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        guard let currentItem = todoItems?[indexPath.row] else { fatalError("FATAL: Error displaying tableview data.") }
        let todoTitle = currentItem.dailyItem ? "• " + currentItem.title : currentItem.title
        cell.delegate = self
        
        //Change label color depending on isMustDo property
        if currentItem.isMustDo {
            cell.textLabel?.textColor = UIColor.black
            
        } else {
            cell.textLabel?.textColor = UIColor.darkGray
        }
        //Cross out label's text depending on completed property
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
        
        //Delete Action
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.deleteItem(at: indexPath)
        }
        deleteAction.image = UIImage(named: "Trash")
        
        //Mark-as-Daily Action
        let markDailyTitle = currentItem.dailyItem ? "Unmark As Daily" : "Mark As Daily"
        let markDailyAction = SwipeAction(style: .default, title: markDailyTitle) { (action, indexPath) in
            self.markDailyItem(item: currentItem, at: indexPath)
        }
        markDailyAction.image = UIImage(named: "Calendar")
        
        return [deleteAction, markDailyAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .drag
        return options
    }
    
    
    
    //MARK: - UIAlert Action Creation Function -- USED ONLY IN SUBCLASSES
    func createAction(title: String, textField: UITextField, mustDo: Bool, daysAhead: Int = 0) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: .default) { (action) in
            if let textInput = textField.text {
                let itemToSave: ToDoItem = ToDoItem()
                itemToSave.title = textInput
                itemToSave.isMustDo = mustDo
                itemToSave.dateCreated = (daysAhead.days).fromNow()!
                if textInput.count > 0 { self.saveItem(item: itemToSave) }
            }
        }
        return action
    }
    
    
    
    //MARK: - Observer Methods
    @objc func viewBecameActive() {
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
    
    func markDailyItem(item: ToDoItem, at indexPath: IndexPath) {
        let deadlineTime = DispatchTime.now() + 0.5 //Used to wait for animation to complete
        let currentCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
        
        do {
            try self.realm.write {
                item.dailyItem = !item.dailyItem
            }
        } catch {
            print("Error modifying ToDoItem attribute in Realm Database: \(error)")
        }
        
        currentCell.hideSwipe(animated: true)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.tableView.reloadData()
        }
    }

}
