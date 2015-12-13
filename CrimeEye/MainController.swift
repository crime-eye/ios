//
//  ViewController.swift
//  CrimeEye
//
//  Created by Gurpreet Paul on 21/11/2015.
//  Copyright © 2015 Gurpreet Paul. All rights reserved.
//

import UIKit
import Siesta
import SwiftyJSON
import MMDrawerController
import Charts

class MainController: UIViewController, ResourceObserver {
    
    typealias CrimeDict = Dictionary<String, AnyObject>
    
    var date: String    = ""
    var monthArray      = PoliceAPI.monthArray
    var crimesArray     = PoliceAPI.crimesArray
    var outcomesDict    = PoliceAPI.outcomesDict
    
    let statusOverlay   = ResourceStatusOverlay()
    
    // MARK: Outlets
    @IBOutlet weak var postcodeLabel:   UILabel!
    @IBOutlet weak var nCrimes:         UILabel!
    @IBOutlet weak var topCrimes:       UILabel!
    @IBOutlet weak var resolvedCrimes:  UILabel!
    @IBOutlet weak var pieChartView:    PieChartView!
    @IBOutlet weak var lineChartView:   LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusOverlay.embedIn(self)
        // load user defaults
        PostcodesAPI.lat = Store.defaults.doubleForKey(Store.LAT)
        PostcodesAPI.lng = Store.defaults.doubleForKey(Store.LONG)
        PostcodesAPI.postcode
                    = Store.defaults.valueForKey(Store.POST_CODE) as! String
        
        // load statistics in to charts if data already exists
        if !self.crimesArray.isEmpty &&
            !self.outcomesDict.isEmpty &&
            !self.monthArray.isEmpty {
                dispatch_async(dispatch_get_global_queue(0, 0)) {
                    self.loadStatistics()
            }
                
        } else {
            // if there is currently no data, make the api calls to collect them
            dispatch_async(dispatch_get_global_queue(0, 0)) {
                self.loadData()
            }
            
        }
        // Set the postcode label to postcode currently in use
        postcodeLabel.text = "in \(PostcodesAPI.postcode)"
        
        // Set some colours for some views
        view.backgroundColor = Style.viewBackground
        nCrimes.textColor = Style.sectionHeaders
        resolvedCrimes.textColor = Style.sectionHeaders
        topCrimes.textColor = Style.sectionHeaders
    }
    
    // handles the refresh button click to reload data
    @IBAction func refreshButton(sender: UIBarButtonItem) {
        loadData()
    }
    
    // function to make api calls for information
    func loadData() {
        let lat = PostcodesAPI.lat
        let lng = PostcodesAPI.lng
        
        // make sure data is the most up to date
        PoliceAPI.getLastUpdated().addObserver(owner: self) {
            resource, event in
            if case .NewData = event {
                PoliceAPI.lastUpdated = resource.json["date"].stringValue
                self.date = String(PoliceAPI.lastUpdated.characters.dropLast(3))
                resource.removeObservers(ownedBy: self)
                self.loadOutcomes(lat, lng: lng)
            }
        }.addObserver(self.statusOverlay).load()
        
        // make api call to collect the crimes for this month
        PoliceAPI
            .getCrimes(lat, long: lng)
            .addObserver(self)
            .addObserver(self.statusOverlay)
            .load()
        
    }
    
    // API calls to police database
    func loadOutcomes(lat: Double, lng: Double){
        let dateArr = self.date.componentsSeparatedByString("-")
        let year = dateArr[0]
        let month = dateArr[1]
        
        // get dates for 6 previous months
        let date1 = previousMonths(5, year: year, month: month)
        let date2 = previousMonths(4, year: year, month: month)
        let date3 = previousMonths(3, year: year, month: month)
        let date4 = previousMonths(2, year: year, month: month)
        let date5 = previousMonths(1, year: year, month: month)
        let date6 = self.date
        
        monthArray = [date1, date2, date3, date4, date5, date6]
        PoliceAPI.monthArray = monthArray
        
        var i = 0;  // make an api call for each date
        for monthDate in monthArray{
            PoliceAPI.getOutcomes(monthDate, lat: lat, long: lng)
                .addObserver(owner: self) {
                resource, event in
                let outResults = resource.json
                
                var outArray = [String]()
                // store each crime's outcome in an array
                for (_, outcome) in outResults {
                    outArray.append(outcome["category"]["code"].stringValue)
                }
                // store the array in a dictionary with the date as key
                self.outcomesDict[monthDate] = outArray
                
                // load statistics to chart once all data has been collected
                if i == self.monthArray.count {
                    PoliceAPI.outcomesDict = self.outcomesDict
                    self.loadStatistics()
                }
                
                
            }.addObserver(self.statusOverlay).load()
            ++i
        }
        
    }
    
    // resource manager for getCrimes
    func resourceChanged(resource: Resource, event: ResourceEvent) {
        crimesArray = []
        
        // If we have some new data
        if resource.latestData != nil {
            let jsonArray = resource.json
            
            // iterate over all the crimes
            for (_, crimes) in jsonArray {
                
                let month       = crimes["month"].stringValue
                let cat         = crimes["category"].stringValue

                // store information on each crime
                let crimeDict = self.crimeToDict(month,
                    category: cat)
                
                self.crimesArray.append(crimeDict)
                
            }
            PoliceAPI.crimesArray = self.crimesArray
            resource.removeObservers(ownedBy: self)
        }
    }
    
    // function to store crime information in a dictionary
    internal func crimeToDict(month: String,
        category: String)
        -> CrimeDict {
            
        var crimeDict = [String: AnyObject]()
        crimeDict["month"]       = month
        crimeDict["category"]    = CrimeFormatter.formatCat(category)
            
        return crimeDict
    }
    
    // function to retrieve string format of a previous month
    internal func previousMonths(monthsToDeduct: Int,
        year: String,
        month: String)
        -> String {
            
        var yearNum     = Int(year)!
        var monthNum    = Int(month)!
        
        // handle if it goes to previous year
        if monthNum - monthsToDeduct < 1{
            --yearNum
            monthNum = (monthNum - monthsToDeduct) % 12
        }
        else {
            monthNum = monthNum - monthsToDeduct
        }
        
        return "\(yearNum)-\(monthNum)"
    }
    
    // loads statistics collected to charts
    func loadStatistics() {
        nCrimes.text = String(self.crimesArray.count)
        
        // sum up all the same category of crimes
        var catDict = [String: Double]()
        for crime in crimesArray {
            if catDict[String(crime["category"]!)] == nil{
                catDict[String(crime["category"]!)] = 1
            } else {
                catDict[String(crime["category"]!)]! += 1
            }
        }
        // sorts in descending number of crimes: get top 3
        let sortedCat = catDict.keys.sort({ (firstKey, secondKey) -> Bool in
            return catDict[firstKey] > catDict[secondKey]
        })
        
        var topCatArray = [String]()
        if sortedCat.count > 3 {
            topCatArray += sortedCat[0..<3]
        } else {
            topCatArray += sortedCat[0..<sortedCat.count]
        }
        
        // load top 3 crime categories to pie chart
        var dataEntries: [ChartDataEntry] = []
        
        for var i = 0; i < topCatArray.count; ++i {
            let dataEntry = ChartDataEntry(value: catDict[sortedCat[i]]!,
                                            xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        let pieChartData = PieChartData(xVals: topCatArray,
            dataSet: pieChartDataSet)
        
        // set colours of each data
        var colors: [UIColor] = []
        colors = [Style.flatRed3, Style.flatBlue5, Style.flatGold4]
        pieChartDataSet.colors = colors
        
        // format pie chart
        pieChartData.setDrawValues(false)
        pieChartDataSet.sliceSpace = 8.0
        pieChartDataSet.drawValuesEnabled = true
        pieChartView.drawSliceTextEnabled = false
        pieChartView.holeColor = Style.viewBackground
        pieChartView.rotationWithTwoFingers = true
        pieChartView.animate(xAxisDuration: NSTimeInterval(4))
        pieChartView.legend.position = .RightOfChart
        pieChartView.legend.textColor = Style.fontColor
        pieChartView.descriptionText = ""
        pieChartView.backgroundColor = Style.viewBackground
        pieChartView.data = pieChartData
        
        // loads number of resolved crimes for previous 6 months to line chart
        var numResolvedArr: [ChartDataEntry] = []
        
        var i = 0
        var monthNameArray: [String] = []
        for month in monthArray {
            let dataEntry = ChartDataEntry(
                value: Double(outcomesDict[month]!.count), xIndex: i)
            numResolvedArr.append(dataEntry)
            monthNameArray.append(CrimeFormatter.formatDate(month))
            ++i
        }
        
        let lineChartDataSet = LineChartDataSet(yVals: numResolvedArr)
        let lineChartData = LineChartData(xVals: monthNameArray,
            dataSet: lineChartDataSet)
        
        // set formatting of line chart
        lineChartData.setDrawValues(true)
        lineChartDataSet.circleColors = [Style.circleColor]
        lineChartDataSet.circleHoleColor = Style.white
        lineChartDataSet.valueTextColor = Style.fontColor
        lineChartView.legend.enabled = false
        lineChartView.descriptionText = ""
        lineChartView.rightAxis.enabled = false
        lineChartView.leftAxis.labelTextColor = Style.fontColor
        lineChartView.leftAxis.startAtZeroEnabled = false
        lineChartView.leftAxis.xOffset = 9.0
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.axisLineColor = Style.fontColor
        lineChartView.xAxis.labelPosition = .Bottom
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.axisLineColor = Style.fontColor
        lineChartView.xAxis.labelTextColor = Style.fontColor
        lineChartView.xAxis.avoidFirstLastClippingEnabled = true
        lineChartView.animate(xAxisDuration: NSTimeInterval(4))
        lineChartView.backgroundColor = Style.viewBackground
        lineChartView.gridBackgroundColor = Style.viewBackground
        lineChartView.data = lineChartData

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openDrawer(sender: UIBarButtonItem) {
        let appD = UIApplication.sharedApplication().delegate as! AppDelegate
        appD.centerContainer!.toggleDrawerSide(MMDrawerSide.Left,
            animated: true, completion: nil)
    }

}

