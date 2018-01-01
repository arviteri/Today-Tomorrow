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

class QuickTodoViewController: UITableViewController, NCWidgetProviding {
    
    var todoItems:Results<ToDoItem>?
    var realm:Realm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        self.preferredContentSize.height = CGFloat(2 * 55)
        tableView.isScrollEnabled = false
        tableView.rowHeight = 55
        print(self.tableView.contentSize.height)
        initiateRealmTest()
        loadItems()
    }
    
    
    //MARK: - TableView Data Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
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
                try realm?.write {
                    selectedItem.completed = !selectedItem.completed
                    selectedItem.dateCompleted = Date()
                }
            } catch {
                print("Error upating ToDoItem attribute after selection: \(error)")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        self.widgetPerformUpdate { (result) in
            self.preferredContentSize.height = CGFloat((self.todoItems?.count)! * 55)
        }
    }
    
    
    
    //MARK: - Widget Methods
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let deadlineTime = DispatchTime.now() + 0.2 //Used to view expansion working improperly. iOS bug.
        if activeDisplayMode == .expanded {
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                self.preferredContentSize.height = CGFloat((self.todoItems?.count)! * 55)
            }
        } else if activeDisplayMode == .compact {
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                self.preferredContentSize = maxSize
            }
        }
    }
    
    
    
    //MARK: - Realm Database Methods
    func initiateRealmTest() {
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
}
