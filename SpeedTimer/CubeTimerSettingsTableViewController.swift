//
//  CubeTimerSettingsTableViewController.swift
//  SpeedTimer
//
//  Created by Vianney Nguyen on 2016-05-04.
//  Copyright © 2016 MatthewWorld. All rights reserved.
//

import UIKit
import CoreMotion

class CubeTimerSettingsTableViewController: UITableViewController {
    @IBOutlet weak var inspectionOutput: UILabel!
    @IBOutlet weak var inspectionSlider: UISlider!
    @IBOutlet weak var smashTableSwitch: UISwitch!
    @IBOutlet weak var smashTableSensitivitySlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !CMMotionManager().isAccelerometerAvailable { // If the device doesn't have an accelerometer, the slider and toggle will be disabled
            smashTableSwitch.isEnabled = false
            smashTableSensitivitySlider.isEnabled = false
        } else {
            smashTableSwitch.isEnabled = true
            smashTableSensitivitySlider.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the saved values of toggles/sliders
        
        // Inspection time
        let inspectionTime = UserData.inspectionTime
        if inspectionTime >= 1 && inspectionTime <= 20 { // Limits of the slider (excludes 0)
            // Display the inspection time
            inspectionOutput.text = "\(inspectionTime)s"
            inspectionSlider.value = Float(inspectionTime)
        } else { // < 1 or > 20. > 20 should be impossible, but it is safe practice to watch out for it
            inspectionOutput.text = "None"
            inspectionSlider.value = 0.0
        }
        
        // Smash table toggle/sliders
        smashTableSwitch.isOn = UserData.smashTableSwitch // Toggle
        let actualSensitivity = (smashTableSensitivitySlider.minimumValue + smashTableSensitivitySlider.maximumValue) - Float(UserData.smashTableSensitivity)
        smashTableSensitivitySlider.value = actualSensitivity
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Called when the user taps on a row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func sliderMoved(_ sender:UISlider) {
        if sender === inspectionSlider {
            // Set for increments of 1
            sender.setValue(roundf(sender.value), animated: false) // Increment of 1
            
            let slideValue = Int(sender.value)
            
            inspectionOutput.text = sender.value > 0 ? "\(slideValue)s" : "None"
            
            // Save the slider value
            UserData.inspectionTime = slideValue

        } else if sender === smashTableSensitivitySlider {
            // Reverse the value. The left should be low sensitivity, which has a higher thershold. The right should be high sensitivty, which has a lower threshold
            let actualValue = (sender.maximumValue + sender.minimumValue) - sender.value
            UserData.smashTableSensitivity = Double(actualValue)
        }
    }
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        if sender === smashTableSwitch { // Smash table toggle
            UserData.smashTableSwitch = sender.isOn
            smashTableSensitivitySlider.isEnabled = sender.isOn // If the toggle is off, the slider is disabled.
        }
    }

}
