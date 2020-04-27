//
//  RecordsSettingTableViewController.swift
//  SpeedTimer
//
//  Created by Vianney Nguyen on 2016-05-01.
//  Copyright © 2016 Paperatus. All rights reserved.
//

import UIKit

class RecordsSettingTableViewController: UITableViewController, UIActionSheetDelegate {
    @IBOutlet weak var averageSliderOut: UILabel!
    @IBOutlet weak var averageSlider: UISlider!
    @IBOutlet weak var clearAllCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set slider move listener
        averageSlider.addTarget(self, action: #selector(sliderMoved(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if the "Clear all" button should be disabled. It will be disabled if no records are stored
        if UserData.records.count > 0 {
            // May have been previously disabled, so re-enable them
            clearAllCell.isUserInteractionEnabled = true
            clearAllCell.textLabel?.isEnabled = true
        } else {
            clearAllCell.isUserInteractionEnabled = false
            clearAllCell.textLabel?.isEnabled = false
        }
        
        averageSlider.value = Float(UserData.averageOption)
        averageSliderOut.text = UserData.averageOption <= 100 ? String(UserData.averageOption) : "All"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        // See if the clicked cell was the "Clear All" cell
        if (tableView.cellForRow(at: indexPath) === clearAllCell) { // Compare by address
            let actionSheet = UIActionSheet(title: "Clear all stored records?",
                                            delegate: self,
                                            cancelButtonTitle: "Cancel",
                                            destructiveButtonTitle: "Clear All")
            actionSheet.show(in: self.view)
        }
    }
    
    @objc func sliderMoved(_ sender:UISlider) {
        if sender === averageSlider {
            // Set for increments of 1
            sender.setValue(roundf(sender.value), animated: false) // Increment of 1
            
            let slideValue = Int(sender.value)
            
            averageSliderOut.text = sender.value <= 100 ? String(slideValue) : "All"
            
            // Save the slider value
            UserData.averageOption = slideValue
        }
    }
    
    // Called when user clicks on the action sheet button (Clear All/Cancel)
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == actionSheet.destructiveButtonIndex { // "Clear All" button
            // Clear the records array, then save
            UserData.records.removeAll()
            
            // Disable the "Clear all" cell
            clearAllCell.isUserInteractionEnabled = false
            clearAllCell.textLabel?.isEnabled = false
        }
    }

}
