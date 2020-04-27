//
//  UserData.swift
//  Cube Timer
//
//  Created by Vianney Nguyen on 2016-04-26.
//  Copyright © 2016 Paperatus. All rights reserved.
//

import Foundation

class UserData {
    class SaveKeys {
        static let RECORD = "records" // Array containing saved records
        static let AVERAGE_OPTION = "averageOption" // Options for determining the average of records
        static let INSPECTION_TIME = "inspectionTime"
        static let SMASH_TABLE_SWITCH = "smashToggle"
        static let SMASH_TABLE_SENSITIVITY = "smashSensitivity"
    }
    
    static let userDefaults = UserDefaults.standard
    
    // Used for fomatting a time given in seconds to mm:ss:SSS
    fileprivate static let dateFormatter:DateFormatter = {
        let d = DateFormatter()
        d.dateFormat = "mm':'ss'.'SSS"
        d.timeZone = TimeZone(secondsFromGMT: 0)
        return d
    }()
    
    static var bestTime:Double = 0.0
    static var worstTime:Double = 0.0
    static var averageTime:Double = 0.0
    
    static var bestTimeIndex = 0
    static var worstTimeIndex = 0
    
    static var averageOption = 0
    static var inspectionTime = 0
    static var smashTableSwitch = false
    static var smashTableSensitivity = 0.0
    
    /*
     Dictionaries contain:
     time              - Double
     date              - String
     localTime         - String
     scrambleAlgorithm - String
     */
    static var records:[[String:AnyObject]] = [] // An array of dictionaries
    
    static func saveAll() {
        saveRecords()
        userDefaults.set(averageOption, forKey: SaveKeys.AVERAGE_OPTION)
        userDefaults.set(inspectionTime, forKey: SaveKeys.INSPECTION_TIME)
        userDefaults.set(smashTableSwitch, forKey: SaveKeys.SMASH_TABLE_SWITCH)
        userDefaults.set(smashTableSensitivity, forKey: SaveKeys.SMASH_TABLE_SENSITIVITY)
    }
    
    static func loadAll() {
        loadRecords()
        averageOption = userDefaults.integer(forKey: SaveKeys.AVERAGE_OPTION)
        inspectionTime = userDefaults.integer(forKey: SaveKeys.INSPECTION_TIME)
        smashTableSwitch = userDefaults.bool(forKey: SaveKeys.SMASH_TABLE_SWITCH)
        smashTableSensitivity = userDefaults.double(forKey: SaveKeys.SMASH_TABLE_SENSITIVITY)
        
        if (averageOption == 0) {
            averageOption = 101 // Default, max in storyboard
        }
        
        if (smashTableSensitivity == 0.0) {
            smashTableSensitivity = 0.2525 // Default, average between min and max in storyboard
        }
    }
    
    static func loadRecords() {
        // Check if the array is nil after converting it to [[String:AnyObject]] retrieved from storage
        if let savedRecords = UserDefaults.standard.array(forKey: SaveKeys.RECORD) as? [[String:AnyObject]] {
            records = savedRecords
        }
    }
    
    static func saveRecords() {
        userDefaults.set(records, forKey: SaveKeys.RECORD)
        userDefaults.synchronize()
    }
    
    
    // Converts a number in seconds to mm:ss:SSS
    static func formatDoubleToTime(_ time:Double) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: time))
    }
    
    static func calculateTimeRecords() {
        if records.count == 0 {
            return
        }
        
        // Set default values
        averageTime = 0
        bestTime = records[0]["time"] as! Double
        worstTime = 0
        
        bestTimeIndex = 0
        worstTimeIndex = 0
        
        // Loop every record in the records array. The time will be combined with the other times while the lowest time is being checked. This is stored in combinedTimes and lowestTimes
        for (index, recordData) in records.enumerated(){ // Record data
            let time:Double = recordData["time"] as! Double

            averageTime += time // Sum up every number. This will be averaged out after the loop

            if (time < bestTime) { // Current time is faster than the current best time
                bestTime = time
                bestTimeIndex = index
            }
            if (time > worstTime) { // Current time is slower than the current worst time
                worstTime = time
                worstTimeIndex = index
            }
        }
        
        averageTime /= Double(records.count) // Average the sum
    }
    
    static func generateDataChartArray(_ amountOfData:Int) -> (times:[Double], date:[String]){
        // Start [amountOfData] before the last index of the array. If that results in a negative number, return 0 instead.
        let startLocation = records.count >= amountOfData ? records.count - amountOfData : 0
        
        var times:[Double] = []
        var dates:[String] = [] // Replaced x-axis date label with 'x' in solved no. 'x'
        
        // The last [amountOfData] objects in the array
        for i in startLocation..<records.count {
            times.append(records[i]["time"] as! Double)
            dates.append(records[i]["date"] as! String)
        }
        
        return (times, dates)
    }
    
    // Gets the average of [amount] records in the records array
    static func averageOfNumber(_ amount:Int) -> Double {
        var indexEnd:Int = 0
        if amount == -1 { // Average of everything in the records array
            indexEnd = records.count
        } else {
            indexEnd = amount > records.count ? records.count : amount
        }
        
        var sum:Double = 0.0
        
        // Loop the array from start to indexEnd
        for i in 0..<indexEnd {
            // Add it to the sum, which will be divided later to retrieve the average amount
            sum += records[i]["time"] as! Double
        }
        
        return sum == 0 ? 0 : sum / Double(indexEnd) // 0/x would display weird results. Return 0 when the sum is 0.
    }
}
