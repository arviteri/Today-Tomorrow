//
//  SettingsViewController.swift
//  Simple Todo
//
//  Created by Andrew Viteri on 1/18/18.
//  Copyright © 2018 Andrew Viteri. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var options = [UITableViewCell]()
    
    @IBOutlet weak var settingsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableViewAttributes()
        createCells()
    }
    
    //MARK: - Settings Table Datasource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = options[indexPath.row]
        return option
    }
    
    //MARK: - Settings Table Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        settingsTable.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Cell Initiation Methods
    func createCells() {
        options.append(settingsTable.dequeueReusableCell(withIdentifier: "customToggleCell") as! NotificationToggleCell)
        options.append(settingsTable.dequeueReusableCell(withIdentifier: "customIntervalCell") as! NotificationInvertvalCell)
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
    }
    
}
