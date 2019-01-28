//
//  TouchEventGestureRecognizer.swift
//  Cube Timer
//
//  Created by Vianney Nguyen on 2016-04-25.
//  Copyright © 2016 MatthewWorld. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

enum CurrentState {
    case touched, released, moved, longPress
}

class TouchEventGestureRecognizer: UIGestureRecognizer {
    var currentState = CurrentState.released // The current state of the touch event
    
    var didPerformLongPress: Bool = false
    
    fileprivate var timer: Timer? = nil; // Timer to check for long presses
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .possible {
            self.state = .began
            currentState = .touched
            
            didPerformLongPress = false
            
            // Create a timer that will check if the event is down after one second. If true, the event will be set to LongPress
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkForLongPressFromTimer), userInfo: nil, repeats: false)
            
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        currentState = .moved
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .ended
        currentState = .released
        
        if let _ = timer {
            timer?.invalidate()
        }
    }
    
    internal func checkForLongPressFromTimer() {
        // Check if the finger is still down
        if currentState != .released {
            // User performed long press
            
            currentState = .longPress
            didPerformLongPress = true
            self.state = .changed
        }
    }
}
