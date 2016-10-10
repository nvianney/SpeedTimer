//
//  ScrambleGenerator
//  Cube Timer
//
//  Created by Vianney Nguyen on 2016-04-25.
//  Copyright © 2016 MatthewWorld. All rights reserved.
//

import Foundation

class ScrambleGenerator {
    
    fileprivate enum Axis {
        case x // L, R
        case y // D, U
        case z // B, F
        case undefined
    }
    
    fileprivate static var notations:[String] = []
    
    static func generateScramble(_ moves: Int) -> String{
        notations = ["F", "B", "U", "D", "L", "R"]
        
        var scramble = "" // The string that contains the shuffle algorithm
        
        var previousAxis:Axis = .undefined
        for _ in 1...moves {
            let randomIndex = Int(arc4random_uniform(UInt32(notations.count))) // Random index of the array
            var selectedNotation = notations[randomIndex] // Object at index 'randomIndex' from the array
            
            // Add extra stuff to the notation (2, '). An 'else if' is used to prevent notations such as U2', F2', etc.
            if randomBool(4) { // If true, a '2' will be added to the notation
                selectedNotation += "2"
            } else if randomBool() { // If true, the prime symbol will be added
                selectedNotation += "'"
            }
            
            // Add the notation to the shuffle string
            scramble += selectedNotation + " "
            
            /* 
             1 - If the current notation's axis is equal to the previous notation's axis, the notation array will not reset to keep the two moves of the same axis removed to prevent algorithms such as U D U.
             
             2 - If the current notation's axis is different than the previous notation's axis, the notation array will reset(adds previous notation back)
             
             3 - After checking, the current notation will be removed and the previous axis will be set to the current axis.
             */
            let currentNotation = notations[randomIndex] // Current notation before it has been removed
            let currentAxis = getAxis(currentNotation) // Current axis
            // 1 is skipped because it isn't required to do anything
            if currentAxis != previousAxis { // 2
                notations = ["F", "B", "U", "D", "L", "R"]
            }
            removeObjectFromNotation(currentNotation) // 3
            previousAxis = getAxis(currentNotation) // 3
        }
        
        return scramble
    }
    
    fileprivate static func randomBool() -> Bool {
        return randomBool(2)
    }
    
    fileprivate static func randomBool(_ chance:Int) -> Bool {
        return arc4random_uniform(UInt32(chance)) == 0 ? true : false
    }
    
    // Swift arrays doesn't come with removing objects, so we'll implement a method that removes an object from the array, rather than removing it by the index
    fileprivate static func removeObjectFromNotation(_ objectToRemove:String) {
        for i in 0...notations.count-1 {
            if notations[i] == objectToRemove {
                notations.remove(at: i)
                return
            }
        }
    }
    
    fileprivate static func getAxis(_ notation:String) -> Axis {
        switch(notation) {
        case "L":
            return Axis.x
        case "R":
            return Axis.x
        case "D":
            return Axis.y
        case "U":
            return Axis.y
        case "B":
            return Axis.z
        case "F":
            return Axis.z
        default:
            return Axis.undefined
        }
    }
}
