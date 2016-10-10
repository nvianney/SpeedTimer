//
//  TimerViewController.swift
//  Cube Timer
//
//  Created by Vianney Nguyen on 2016-04-24.
//  Copyright © 2016 MatthewWorld. All rights reserved.
//

import UIKit
import CoreMotion

class TimerViewController: UIViewController {
    @IBOutlet weak var bestTimeLabel: UILabel!
    @IBOutlet weak var averageTimeLabel: UILabel!
    @IBOutlet weak var statusBar: UIView!
    @IBOutlet weak var touchpad: UIView!
    @IBOutlet weak var algorithmLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    let SHUFFLE_MOVES = 20
    let motionManager = CMMotionManager()
    
    // Date formatting: http://waracle.net/iphone-nsdateformatter-date-formatting-table/
    let dateFormatter:DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM d',' y"
        return df
    }()
    // Time formatting
    let timeFormatter:DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "h':'mm.ss a"
        return df
    }()
    let inspectionTimeFormatter:DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "s.S"
        return df
    }()
    
    // Stopwatch data
    var stopwatchTimer:Timer? = nil // Timer for updating the timerText
    var isCounting = false // True if the stopwatch is running, false otherwise
    var stopwatchStartTime:Date? = nil // The time the stopwatch was executed
    var inspectionTimer:Timer? = nil
    var inspectionStartTime:Date? = nil
    
    // Colors
    let blueBarColor = UIColor.init(red: 0, green: 200.0/255.0, blue: 1, alpha: 1)
    let yellowBarColor = UIColor.init(red: 1, green: 1, blue: 0, alpha: 1)
    let timerOffColor = UIColor.init(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
    
    let darkTabBarImage = UIImage().imageWithColor(UIColor(white: 0.1, alpha: 1))
    
    var initialAcceleration:Double? = nil // For "Smash table to stop". The initial acceleration the device had when the timer started
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set the shuffle algorithm
        algorithmLabel.text = ScrambleGenerator.generateScramble(SHUFFLE_MOVES)
        
        // Set text color of the timerText
        timerLabel.textColor = timerOffColor
        
        // Set up touch events for the touchpad
        let touchEventListener = TouchEventGestureRecognizer(target: self, action: #selector(touchpadTouchEvent(_:))) // Touch event listener
        
        // Add touch listeners to the touchpad
        touchpad.addGestureRecognizer(touchEventListener)
        
        updateRecordInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateRecordInfo()
        
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        tabBarController?.tabBar.backgroundImage = darkTabBarImage
    }
    
    // If the "More" screen is in a sub-screen, tapping from Timer -> More will not fix the color
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        tabBarController?.tabBar.backgroundImage = nil
    }
    
    var overrideStart = false // If true, releasing the finger from the screen will start the stopwatch
    func touchpadTouchEvent(_ sender:TouchEventGestureRecognizer) {
        let inspectionTime = UserData.inspectionTime
        
        if isCounting == false { // Timer isn't running
            switch sender.currentState {
            case .touched:
                if inspectionTime == 0 { // No inspection
                    
                    // Display the text in red to prepare the user
                    timerLabel.text = "00:00.000"
                    timerLabel.textColor = UIColor.red
                    statusBar.backgroundColor = UIColor.red
                    
                } else if let timer = inspectionTimer { // The inspection timer is already running
                    
                    // Stop timer
                    timer.invalidate()
                    inspectionTimer = nil
                    
                    // Force the stopwatch to start after the user releases the finger from the screen
                    overrideStart = true
                    
                    // Display the timer as if the inspection is off and the user is holding the screen
                    timerLabel.textColor = UIColor.green
                    statusBar.backgroundColor = yellowBarColor
                    timerLabel.text = "00:00.000"

                } else { // Inspection is on, but not yet running
                    
                    // Display the inspection time
                    timerLabel.text = "\(inspectionTime)"
                    timerLabel.textColor = UIColor.white
                    statusBar.backgroundColor = UIColor.green
                }
                
                // Disable tab bar to prevent accidental clicks
                shouldTabBarBeEnabled(false)
                
            case .released:
                if (sender.didPerformLongPress && inspectionTime == 0) || overrideStart { // No inspection, timer is not running OR when the user taps on the screen while the inspection time is running.
                    
                    // Disable overriding
                    overrideStart = false
                    
                    // Set the color of the text
                    timerLabel.textColor =  UIColor.white
                    statusBar.backgroundColor = UIColor.green
                    
                    // Check if the user enabled "Smash table to stop", and the accelerometer is present
                    if UserData.smashTableSwitch && motionManager.isAccelerometerAvailable {
                        motionManager.accelerometerUpdateInterval = 0.01
                        motionManager.startAccelerometerUpdates()
                        canSetInitialAcceleration = true
                    }
                    
                    // Start the timer
                    stopwatchTimer = Timer.scheduledTimer(timeInterval: 1.0/30.0, target: self, selector: #selector(updateTimerText), userInfo: nil, repeats: true)
                    stopwatchStartTime = Date()
                    isCounting = true;
                    
                } else if inspectionTime == 0 { // Released after touch. Inspection off
                    timerLabel.textColor = timerOffColor
                    statusBar.backgroundColor = UIColor.lightGray
                    shouldTabBarBeEnabled(true)
                    
                    // Disable screen dimming
                    UIApplication.shared.isIdleTimerDisabled = true
                    
                } else { // Inspection on. Start inspection
                    
                    statusBar.backgroundColor = yellowBarColor // Yellow status bar
                    
                    // Disable screen dimming
                    UIApplication.shared.isIdleTimerDisabled = true
                    
                    // Setup the inspection timer
                    inspectionStartTime = Date()
                    inspectionTimer = Timer.scheduledTimer(timeInterval: 1.0/30.0, target: self, selector: #selector(updateInspection), userInfo: nil, repeats: true)
                }
                
            case .longPress:
                if inspectionTime == 0 { // Only start the timer after a long press when the inspection is off
                    timerLabel.textColor = UIColor.green
                    statusBar.backgroundColor = yellowBarColor
                }
            default:
                break;
            }
        } else {
            if sender.currentState == .touched { // User touched screen while timer is running
                // Reset timer
                stopwatchTimer?.invalidate()
                stopwatchTimer = nil
                // Stop the timer first to prevent it from counting after the user stopped
                var time = updateTimerText() // Final update
                
                motionManager.stopAccelerometerUpdates()
                
                // Re-enable screen dimming
                UIApplication.shared.isIdleTimerDisabled = false
                
                time = roundNumber(time * 1000.0) / 1000.0 // Round to 3 decimal places
                
                // Save the data to the records array
                let date = Date()
                var recordData:[String:AnyObject] = [:]
                recordData["time"] = time as AnyObject?
                recordData["date"] = dateFormatter.string(from: date) as AnyObject?
                recordData["localTime"] = timeFormatter.string(from: date) as AnyObject?
                recordData["scrambleAlgorithm"] = algorithmLabel.text! as AnyObject?
                UserData.records.insert(recordData, at: 0) // Add to array
                
                updateRecordInfo() // Update bottom text (average time, best time)
                
                shouldTabBarBeEnabled(true)
                
                // Visual feedback
                statusBar.backgroundColor = blueBarColor // Bar color
                timerLabel.textColor = UIColor.green // Text color
                Timer.scheduledTimer( // Restore text color after an amount of time
                    timeInterval: 0.5, // In seconds
                    target: self,
                    selector: #selector(stoppedTimerTextColorAnimation), // Method to call after 'x' seconds
                    userInfo: nil,
                    repeats: false)
                
                algorithmLabel.text = ScrambleGenerator.generateScramble(SHUFFLE_MOVES) // Change scramble
            } else if sender.currentState == .released {
                isCounting = false
            }
        }
    }

    var canSetInitialAcceleration = false
    // Updates the text of the timer. Called when the stopwatch is running. Also checks for accelerometer updates
    func updateTimerText() -> Double {
        let currentDate = Date.init() // Current time
        let timeInterval = currentDate.timeIntervalSince(stopwatchStartTime!) // Interval between start time and current time
        
        timerLabel.text = UserData.formatDoubleToTime(timeInterval) // Set the timerText to the formatted date text
        
        // Check if the user enabled "Smash table to stop"
        if UserData.smashTableSwitch && motionManager.isAccelerometerActive {
            
            if let data = motionManager.accelerometerData?.acceleration { // Nil when the accelerometer didn't update because of the time interval
                
                let accelerationAvg = (data.x + data.y + data.z) / 3.0 // Acceleration
                
                // Check if the user smashed the table by measuring the difference between the current acceleration and the initial acceleration
                if let startAcceleration = initialAcceleration { // Check if the double isn't nil
                    
                    var diff = accelerationAvg - startAcceleration // Get difference
                    diff = diff < 0 ? -diff : diff // Abs
                    
                    if diff > UserData.smashTableSensitivity { // Difference > Threshold
                        
                        motionManager.stopAccelerometerUpdates() // EXC_BAD_ACCESS in UserData will appear in formatDoubleFromTime(_:) without this line
                        
                        let touchGesture = TouchEventGestureRecognizer()
                        touchGesture.currentState = .touched
                        touchpadTouchEvent(touchGesture) // Simulate touch down
                        touchGesture.currentState = .released
                        touchpadTouchEvent(touchGesture) // Touch up
                        
                        initialAcceleration = nil
                    }
                    
                }
                
                // Check if the initial acceleration has been set
                if canSetInitialAcceleration {
                    canSetInitialAcceleration = false
                    initialAcceleration = accelerationAvg
                }
            }
        }
        
        return timeInterval
    }
    
    func updateInspection() {
        // Get the duration since the inspection has started, subtracted from the inspectionTime
        let timeLeft = Double(UserData.inspectionTime) - Date().timeIntervalSince(inspectionStartTime!)
        
        timerLabel.text = inspectionTimeFormatter.string(from: Date(timeIntervalSince1970: timeLeft))
        
        if timeLeft <= 0 {
            // Simulate a touch and release on the touchpad
            let temp = TouchEventGestureRecognizer()
            
            temp.currentState = .touched // Touch
            touchpadTouchEvent(temp)
            
            temp.currentState = .released // Release
            touchpadTouchEvent(temp)
        }
    }
    
    // Called after the user stopped the stopwatch
    func stoppedTimerTextColorAnimation() {
        if timerLabel.textColor == UIColor.green { // In case if the user tapped the screen before this method has been called. Tapping causes the text color to change
            timerLabel.textColor = UIColor.white
        }
    }
    
    // Updates the "Average time" text and the "Best time" text
    func updateRecordInfo() {
        var newAverageTimeText = "Average Time:\n00:00.000" // Default text
        var newBestTimeText = "Best Time:\n00:00.000" // Default text
        
        if UserData.records.count > 0 { // There are saved records
            
            UserData.calculateTimeRecords()
            
            // Set the text to the determined time
            newAverageTimeText = "Average Time:\n\(UserData.formatDoubleToTime(UserData.averageTime))"
            newBestTimeText = "Best Time:\n\(UserData.formatDoubleToTime(UserData.bestTime))"
        }
        
        // Set the text
        averageTimeLabel.text = newAverageTimeText
        bestTimeLabel.text = newBestTimeText
    }
    
    func shouldTabBarBeEnabled(_ enabled:Bool) {
        // Loop every tab in the UITabBar
        for tabs:UITabBarItem in self.tabBarController!.tabBar.items! {
            tabs.isEnabled = enabled
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func roundNumber(_ number:Double) -> Double {
        let decimalOnly = number - Double(Int(number));
        return decimalOnly < 0.5 ? Double(Int(number)) : Double(Int(number) + 1);
    }
    
    
}

// http://stackoverflow.com/questions/990976/how-to-create-a-colored-1x1-uiimage-on-the-iphone-dynamically
extension UIImage {
    func imageWithColor(_ color:UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

