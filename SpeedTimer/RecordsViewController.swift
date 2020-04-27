//
//  RecordsViewController.swift
//  Cube Timer
//
//  Created by Vianney Nguyen on 2016-04-24.
//  Copyright © 2016 Paperatus. All rights reserved.
//

import UIKit

class RecordsViewController: UIViewController {
    @IBOutlet weak var averageTitleInfo: UILabel!
    var startEditingBarButtonItem:UIBarButtonItem? = nil
    var stopEditingBarButtonItem:UIBarButtonItem? = nil
    
    // Information labels
    @IBOutlet weak var solvesLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var bestLabel: UILabel!
    @IBOutlet weak var worstLabel: UILabel!
    
    // TableView containing records
    @IBOutlet weak var recordsTableView: RecordsTableViewDelegate!
    
    // -> Loaded -> Appeared. viewDidLoad() will only be called once.
    // Called when the view is disiplayed onto the screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        tabBarController?.tabBar.backgroundImage = nil
        
        let averageOption = UserData.averageOption
        if averageOption >= 5 && averageOption <= 100 { // Min/max value for slider located in MoreScreen storyboard
            averageTitleInfo.text = "Average of \(averageOption):"
        } else {
            averageTitleInfo.text = "Average Time:"
        }
        
        updateRecordsData() // Display the user's records. Includes the average/best/worst time and the table
    }
    
    func updateRecordsData() {
        // Reload the recordsTableView
        recordsTableView.reloadData()
        
        UserData.calculateTimeRecords()
        
        let averageOption = UserData.averageOption
        
        averageLabel.text = UserData.formatDoubleToTime(UserData.averageOfNumber(averageOption)) // Changed from UserData.averageTime. The user can now choose between average of all or average of 5, etc.
        bestLabel.text = UserData.formatDoubleToTime(UserData.bestTime)
        worstLabel.text = UserData.formatDoubleToTime(UserData.worstTime)
        
        solvesLabel.text = "Solves: \(UserData.records.count)"
    }

    // Called when the view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordsTableView.delegate = recordsTableView // Listener
        recordsTableView.dataSource = recordsTableView // Data source
        
        // Instantiate BarButtonItems
        startEditingBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(userTappedBarButtonItem(_:)))
        stopEditingBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(userTappedBarButtonItem(_:)))
        
        // Set the BarButtonItem to the ViewController
        self.navigationItem.rightBarButtonItem = startEditingBarButtonItem
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Called when the user taps the BarButtonItem. This is set in viewDidLoad
    @objc func userTappedBarButtonItem(_ sender: UIBarButtonItem) {
        let currentlyEditing = recordsTableView.isEditing
        var nextBarButtonItem:UIBarButtonItem? = nil
        
        if currentlyEditing { // Currently editing
            nextBarButtonItem = startEditingBarButtonItem
        } else { // Not editing
            nextBarButtonItem = stopEditingBarButtonItem
        }
        navigationItem.rightBarButtonItem = nextBarButtonItem
        recordsTableView.setEditing(!currentlyEditing, animated: true)
        
        if sender === stopEditingBarButtonItem { // User stopped editing
            updateRecordsData()
        }
    }
}

class RecordsTableViewDelegate: UITableView, UITableViewDataSource, UITableViewDelegate {
    let grayColor = UIColor(white: 0.95, alpha: 1)
    let greenColor = UIColor(red: 209.0/255.0, green: 1, blue: 209.0/255.0, alpha: 1)
    let redColor = UIColor(red: 1, green: 209.0/255.0, blue: 209.0/255.0, alpha: 1)
    
    // Retrieve the amount of rows in the UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserData.records.count
    }
    
    // Method will be called [UserData.records.count] times. Each call will return a custom UITableViewCell modified for the current row which will be added to the UITableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cellIdentifier = "TimedRecord" // Identifier set in storyboard in the prototype cell
        
        // Retrieve a cell from this tableView, then cast it to RecordsTableCell, since the cell's parent is set to RecordsTableCell in the storyboard
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RecordsTableCell
        
        UserData.calculateTimeRecords() // Update the data for the most recent best/worst index
        
        // Set the text of the row
        tableViewCell.timeLabel.text = UserData.formatDoubleToTime((UserData.records[(indexPath as NSIndexPath).row]["time"] as? Double)!)
        tableViewCell.dateLabel.text = UserData.records[(indexPath as NSIndexPath).row]["date"] as? String
        
        // Set the color of the row based on the time
        tableViewCell.contentView.backgroundColor = {
            switch((indexPath as NSIndexPath).row) {
            case UserData.bestTimeIndex: // Fastest row
                return greenColor
            case UserData.worstTimeIndex: // Slowest row
                return redColor
            default: // Neither
                return grayColor
            }
            
            }()
        
        return tableViewCell
    }
    
    // Allow every row in the table to be edited by the user
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // The editing style when the user taps on the edit(BarButtonItem) button
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Called when the user taps on delete on a cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            UserData.records.remove(at: (indexPath as NSIndexPath).row)
            self.deleteRows(at: [indexPath], with: .bottom)
        }
    }
    
    // Called when the user taps on a cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the data of the row
        let rowRecordData = UserData.records[(indexPath as NSIndexPath).row]
        
        // Create a dialog with details of the solve
        UIAlertView(
            title: UserData.formatDoubleToTime(rowRecordData["time"] as! Double),
            message: "Solved on \(rowRecordData["date"]!) at \(rowRecordData["localTime"]!).\n\n" +
                "Scramble:\n\(rowRecordData["scrambleAlgorithm"]!)",
            delegate: nil,
            cancelButtonTitle: "Close").show()
    }
}

