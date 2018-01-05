//
//  QuickTodoViewController.swift
//  QuickTodo
//
//  Created by Andrew Viteri on 12/31/17.
//  Copyright © 2017 Andrew Viteri. All rights reserved.
//

import UIKit
import NotificationCenter
import RealmSwift
import SwiftDate
import BEMCheckBox

class QuickTodoViewController: UITableViewController, NCWidgetProviding, BEMCheckBoxDelegate {
    
    var todoItems:Results<ToDoItem>?
    var realm:Realm?
    var rowHeight:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defineTableViewProps()
        initiateRealm()
        loadItems()
    }
    
    
    
    //MARK: - TableView Property Methods
    func defineTableViewProps() {
        self.tableView.register(UINib(nibName: "CheckBoxCell", bundle: nil), forCellReuseIdentifier: "checkBoxCell")
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        self.preferredContentSize.height = CGFloat(2 * 55)
        tableView.isScrollEnabled = false
        if let maxCompactHeight = self.extensionContext?.widgetMaximumSize(for: .compact).height {
            tableView.rowHeight = maxCompactHeight/2
            rowHeight = tableView.rowHeight
        } else {
            rowHeight = 55
        }
    }
    
    
    
    //MARK: - TableView Data Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CheckBoxCell = tableView.dequeueReusableCell(withIdentifier: "checkBoxCell", for: indexPath) as! CheckBoxCell
        cell.checkBoxView.delegate = self
        cell.checkBoxView.isUserInteractionEnabled = false
        guard let currentItem = todoItems?[indexPath.row] else {fatalError("FATAL: Error displaying tableview data.")}
        
        //Change label color depending on isMustDo property
        if currentItem.isMustDo {
            cell.label?.textColor = UIColor.black
            cell.checkBoxView.tintColor = UIColor.black
        } else {
            cell.label?.textColor = UIColor.darkGray
            cell.checkBoxView.tintColor = UIColor.darkGray
        }
        //Cross out label's text depending on completed property
        let todoTitle = currentItem.dailyItem ? "• " + currentItem.title : currentItem.title
        cell.label?.attributedText = NSMutableAttributedString(string: todoTitle)
        cell.accessoryType = .none
        
        return cell
    }
    
    
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedItem = todoItems?[indexPath.row] else { fatalError("Error while selecting ToDoItem") }
        let currentCell = tableView.cellForRow(at: indexPath) as! CheckBoxCell
        currentCell.checkBoxView.setOn(true, animated: true)
        
        let deadlineTime = DispatchTime.now() + 0.5 //Used to wait for animation to complete
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            currentCell.checkBoxView.on = false
            self.markAsCompleted(item: selectedItem)
            tableView.reloadData()
            
            //Update widget height after item is removed
            self.widgetPerformUpdate { (result) in
                self.preferredContentSize.height = CGFloat((self.todoItems?.count)!) * self.rowHeight
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    
    //MARK: - Widget Methods
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let deadlineTime = DispatchTime.now() + 0.2 //Used to view expansion working improperly. iOS bug.
        if activeDisplayMode == .expanded {
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                self.preferredContentSize.height = CGFloat((self.todoItems?.count)!) * self.rowHeight
            }
        } else if activeDisplayMode == .compact {
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                self.preferredContentSize = maxSize
            }
        }
    }
    
    
    
    //MARK: - Realm Database Methods
    func initiateRealm() {
        //Change Realm Database Location
        let fileURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.todo.data")!
            .appendingPathComponent("default.realm")
        let config = Realm.Configuration(fileURL: fileURL)
        
        //Attempt to initiate Realm Database
        do {
            let initiationRealm : Realm = try Realm(configuration: config)
            initiationRealm.refresh()
            realm = initiationRealm
        } catch {
            fatalError("Error initiating Realm Database:  \(error)")
        }
    }
    
    func loadItems() {
        let endOfDay : [Int] = [23-Date().hour, 59-Date().minute, 59-Date().second]
        let tomorrow = (endOfDay[0].hours + endOfDay[1].minutes + endOfDay[2].seconds).fromNow()! as NSDate
        todoItems = realm?.objects(ToDoItem.self).filter(NSPredicate(format: "completed == false AND dailyItem == false AND dateCreated <= %@", tomorrow)).sorted(byKeyPath: "isMustDo", ascending: false)
        tableView.reloadData()
    }
    
    func markAsCompleted(item: ToDoItem) {
        do {
            try self.realm?.write {
                item.completed = !item.completed
                item.dateCompleted = Date()
            }
        } catch {
            print("Error upating ToDoItem attribute after selection: \(error)")
        }
    }
}
