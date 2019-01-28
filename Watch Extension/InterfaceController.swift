//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Vianney Nguyen on 2016-05-18.
//  Copyright © 2016 MatthewWorld. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    @IBOutlet var touchpad: WKInterfaceButton!
    
    let waitingColor = UIColor(white: 0.15, alpha: 1)
    let runningColor = UIColor(red: 0, green: 0.9, blue: 0, alpha: 1)
    let doneColor = UIColor(red: 0, green: 200.0/255.0, blue: 1, alpha: 1)
    
    var isRunning = false
    var stopwatchTimer:Timer? = nil
    var stopwatchStartTime:Date? = nil

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        isRunning = false
        stopwatchTimer?.invalidate()
        stopwatchTimer = nil
        touchpad.setBackgroundColor(waitingColor)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    // This method is fired when the user touches and releases the button
    @IBAction func didPressTouchpad() {
        if !isRunning { // Timer is off
            isRunning = true
            startTimer()
        } else { // Timer is on
            isRunning = false
            stopwatchTimer?.invalidate()
            updateTimer() // Final update
            touchpad.setBackgroundColor(doneColor)
            Timer.scheduledTimer(timeInterval: 1,
                                                   target: self,
                                                   selector: #selector(restoreTouchpadColor),
                                                   userInfo: nil,
                                                   repeats: false)
        }
    }
    
    func restoreTouchpadColor() {
        if !isRunning {
            touchpad.setBackgroundColor(waitingColor)
        }
    }
    
    // Initializes NSTimer to repeatedly call a function
    func startTimer() {
        stopwatchTimer = Timer.scheduledTimer(
            timeInterval: 1.0/30.0,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true)
        stopwatchStartTime = Date()
        touchpad.setBackgroundColor(runningColor)
    }
    
    func updateTimer() {
        let timeInterval = Date().timeIntervalSince(stopwatchStartTime!)
        touchpad.setTitle(String(format: "%.1f", timeInterval))
    }
}
