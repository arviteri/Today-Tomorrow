//
//  NotificationIntervalController.swift
//  Simple Todo
//
//  Created by Andrew Viteri on 1/19/18.
//  Copyright © 2018 Andrew Viteri. All rights reserved.
//

import UIKit

class NotificationIntervalController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var intervals = [NotificationInterval]()
    
    @IBOutlet weak var intervalsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTableViewAttributes()
        createIntervals()
    }

    
    //MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intervals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let intervalCell = tableView.dequeueReusableCell(withIdentifier: "IntervalCell", for: indexPath)
        intervalCell.textLabel?.text = intervals[indexPath.row].title
        intervalCell.accessoryType = intervals[indexPath.row].checked ? .checkmark : .none
        return intervalCell
    }
    
    //MARK - TableView Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        uncheckPreviousInterval(index: UserDefaults.standard.integer(forKey: "Selected_Interval"))
        UserDefaults.standard.set(indexPath.row, forKey: "Selected_Interval")
        intervals[indexPath.row].checked = true
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - TableView Inititaion Methods
    func setTableViewAttributes() {
        intervalsTable.delegate = self
        intervalsTable.dataSource = self
        intervalsTable.rowHeight = 44
        intervalsTable.layer.borderWidth = 0.4
        intervalsTable.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    //MARK: - Interval Cell Methods
    func createIntervals() {
        for intervalTitle in NotificationInterval.intervalTitles {
            let isChecked = UserDefaults.standard.integer(forKey: "Selected_Interval") == NotificationInterval.intervalTitles.index(of: intervalTitle) ? true : false
            intervals.append(NotificationInterval(title: intervalTitle, checked: isChecked))
        }
    }
    
    func uncheckPreviousInterval(index: Int) {
        intervals[index].checked = false
    }

}
