//
//  TodayTableView.swift
//  
//
//  Created by Andrew Viteri on 12/30/17.
//

import UIKit

class TodayTableView: SwipeTableViewController {
    
    var todoItems:[Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    //MARK: - Bar Button IBActions
    @IBAction func dayButtonPressed(_ sender: UIBarButtonItem) {
        if sender.tag == 0 {
            performSegue(withIdentifier: "goToYesterday", sender: self)
        }
        else if sender.tag == 1 {
            performSegue(withIdentifier: "goToTomorrow", sender: self)
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    }
    
}
