//
//  SettingsViewController.swift
//  Simple Todo
//
//  Created by Andrew Viteri on 1/18/18.
//  Copyright © 2018 Andrew Viteri. All rights reserved.
//

import UIKit
import NotificationCenter

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var options = [UITableViewCell]()
    
    @IBOutlet weak var settingsTable: UITableView!
    @IBOutlet weak var creditsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewBecameActive), name: .UIApplicationDidBecomeActive, object: nil)
        setTableViewAttributes()
        createCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        settingsTable.reloadData()
    }
    
    //MARK: - Settings Table Datasource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == settingsTable {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == settingsTable {
            let optionCell = options[indexPath.row]
            
            if optionCell is NotificationToggleCell {
                (optionCell as! NotificationToggleCell).toggle.isOn = UIApplication.shared.isRegisteredForRemoteNotifications ? true : false
            }
            if optionCell is NotificationIntervalCell {
                (optionCell as! NotificationIntervalCell).intervalLabel.text = NotificationInterval.intervalTitles[UserDefaults.standard.integer(forKey: "Selected_Interval")]
            }
            
            return optionCell
        } else {
            let creditCell = creditsTable.dequeueReusableCell(withIdentifier: "CreditsCell", for: indexPath)
            creditCell.textLabel?.text = "Credits"
            creditCell.accessoryType = .disclosureIndicator
            return creditCell
        }
    }
    
    //MARK: - Settings Table Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == settingsTable {
            let option = tableView.cellForRow(at: indexPath)
            if option is NotificationIntervalCell {
                performSegue(withIdentifier: "goToIntervals", sender: self)
            }
        } else {
            performSegue(withIdentifier: "goToCredits", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Cell Initiation Methods
    func createCells() {
        let toggleCell = settingsTable.dequeueReusableCell(withIdentifier: "customToggleCell") as! NotificationToggleCell
        let intervalCell = settingsTable.dequeueReusableCell(withIdentifier: "customIntervalCell") as! NotificationIntervalCell
        options.append(toggleCell)
        options.append(intervalCell)
    }
    
    //MARK: - TableView Initiation Methods
    func setTableViewAttributes() {
        settingsTable.delegate = self
        settingsTable.dataSource = self
        settingsTable.register(UINib(nibName: "ToggleCell", bundle: nil), forCellReuseIdentifier: "customToggleCell")
        settingsTable.register(UINib(nibName: "SelectionCell", bundle: nil), forCellReuseIdentifier: "customIntervalCell")
        settingsTable.rowHeight = 44
        settingsTable.layer.borderWidth = 0.4
        settingsTable.layer.borderColor = UIColor.lightGray.cgColor
        
        creditsTable.delegate = self
        creditsTable.dataSource = self
        creditsTable.rowHeight = 44
        creditsTable.layer.borderWidth = 0.4
        creditsTable.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    //MARK: - View Methods
    @objc func viewBecameActive() {
        settingsTable.reloadData()
    }
    
}
