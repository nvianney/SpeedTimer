//
//  ReordsGraphViewController.swift
//  SpeedTimer
//
//  Created by Vianney Nguyen on 2016-04-28.
//  Copyright © 2016 Paperatus. All rights reserved.
//

import UIKit
import Charts

class RecordsGraphViewController: UIViewController {
    @IBOutlet weak var lineChartView: LineChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        lineChartView.noDataText = "No stored records. Go solve a cube!"
        lineChartView.noDataTextColor = UIColor.darkText
        
        lineChartView.chartDescription!.text = "Top 100 Recent Solves"
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let recordData = UserData.generateDataChartArray(100)
        lineChartView.leftAxis.removeAllLimitLines()
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        tabBarController?.tabBar.backgroundImage = nil
        setChart(recordData.times)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setChart(_ dataPoints:[Double]) {
        if dataPoints.count == 0 {
            return
        }
        
        // Generate an array of numbers from [records.count-100] to [records.count]
        var numberArrayXAxis:[String] = []
        let startIndex = UserData.records.count < 100 ? 0 : UserData.records.count - 100
        for i in startIndex..<UserData.records.count {
            numberArrayXAxis.append(String(i))
        }
        
        let valueFormatter = LineChartNumberFormatter()
        
        // Empty array for data points
        var lineChartDataEntries:[ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            // Create a ChartDataEntry based off of the dataPoints args and add it to the array
            // The graph is suppposed to have more recent items to the right, but this array makes more recent items to the left. The array needs to be reversed to fix the problem.
            lineChartDataEntries.append(ChartDataEntry(x: dataPoints[dataPoints.count - i - 1], y: Double(i)))
        }
        
        // The array containing a set of points connected by lines (line chart)
        let lineChartDataSet:LineChartDataSet = LineChartDataSet(entries: lineChartDataEntries, label:"Time")
        lineChartDataSet.lineWidth = 3 // Line width
        lineChartDataSet.setColor(UIColor(red: 50.0/255.0, green: 200.0/255.0, blue: 150.0/255.0, alpha: 1), alpha: 1) // Line color
        lineChartDataSet.drawCirclesEnabled = false // Circles on P(x, y)
        lineChartDataSet.drawValuesEnabled = false // Draw y value on P(x, y)
        lineChartDataSet.mode = .horizontalBezier // Rounded curves
        
        // Create the data based on the dataSet
        let lineChartData = LineChartData(dataSets: [lineChartDataSet])
        
        // Average line
        let averageLine = ChartLimitLine(limit: UserData.averageTime, label: "Average")
        averageLine.lineColor = UIColor(red: 232.0/255.0, green: 156.0/255.0, blue: 102.0/255.0, alpha: 1)
        
        // Set the data
        lineChartView.data = lineChartData // Data
        lineChartView.leftAxis.valueFormatter = valueFormatter // The left y-axis text
        lineChartView.leftAxis.addLimitLine(averageLine) // Average line
        lineChartView.rightAxis.drawLabelsEnabled = false // Disable text on the right y-axis
        lineChartView.legend.enabled = false // Disable legend
        lineChartView.setScaleEnabled(false) // Disable zooming
        lineChartView.dragEnabled = false // Disable dragging
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.rightAxis.axisMinimum = 0
        lineChartView.sizeToFit() // Resize to fit the chart onto the screen
        lineChartView.animate(yAxisDuration: 1.0) // Animate the points
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// For fomatting the numbers on the left axis on the line chart. Converts number in double to 00:00.000
class LineChartNumberFormatter : NSObject, IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return UserData.formatDoubleToTime(value)
    }
}
