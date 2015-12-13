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
    
    var date: String = ""
    var monthArray = PoliceAPI.monthArray
    var crimesArray = PoliceAPI.crimesArray
    var outcomesDict = PoliceAPI.outcomesDict
    
    let statusOverlay = ResourceStatusOverlay()
    
    // MARK: Outlets
    @IBOutlet weak var postcodeLabel: UILabel!
    @IBOutlet weak var nCrimes: UILabel!
    @IBOutlet weak var topCrimes: UILabel!
    @IBOutlet weak var resolvedCrimes: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var lineChartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusOverlay.embedIn(self)
        PostcodesAPI.lat = Store.defaults.valueForKey(Store.LAT) as! Double
        PostcodesAPI.lng = Store.defaults.valueForKey(Store.LONG) as! Double
        PostcodesAPI.postcode = Store.defaults.valueForKey(Store.POST_CODE) as! String
        
        if (!self.crimesArray.isEmpty && !self.outcomesDict.isEmpty && !self.monthArray.isEmpty) {
            loadStatistics()
        }
        else {
            loadData()
        }
        
        postcodeLabel.text = "in \(PostcodesAPI.postcode)"
        view.backgroundColor = Style.viewBackground
        nCrimes.textColor = Style.sectionHeaders
        resolvedCrimes.textColor = Style.sectionHeaders
        topCrimes.textColor = Style.sectionHeaders
        }
    
    @IBAction func refreshButtion(sender: UIBarButtonItem) {
        loadData()
    }
    
    func loadData() {
        let lat = PostcodesAPI.lat
        let lng = PostcodesAPI.lng
        print(lat)
        print(lng)
    
        PoliceAPI.getLastUpdated().addObserver(owner: self) {
            resource, event in
            if case .NewData = event {
                PoliceAPI.lastUpdated = resource.json["date"].stringValue
                self.date = String(PoliceAPI.lastUpdated.characters.dropLast(3))
                print(PoliceAPI.lastUpdated)
                resource.removeObservers(ownedBy: self)
                self.loadOutcomes(lat, lng: lng)
            }
        }.addObserver(self.statusOverlay).load()
        
    }
    
    func loadOutcomes(lat: Double, lng: Double){
        let dateArr = self.date.componentsSeparatedByString("-")
        let year = dateArr[0]
        let month = dateArr[1]
        
        let date1 = previousMonths(5, year: year, month: month)
        let date2 = previousMonths(4, year: year, month: month)
        let date3 = previousMonths(3, year: year, month: month)
        let date4 = previousMonths(2, year: year, month: month)
        let date5 = previousMonths(1, year: year, month: month)
        let date6 = self.date
        
        monthArray = [date1, date2, date3, date4, date5, date6]
        PoliceAPI.monthArray = monthArray
        
        var i = 0;
        for monthDate in monthArray{
            PoliceAPI.getOutcomes(monthDate, lat: lat, long: lng).addObserver(owner: self) {
                resource, event in
                let outResults = resource.json
                
                var outArray = [String]()
                
                for (_, outcome) in outResults {
                    outArray.append(outcome["category"]["code"].stringValue)
                }
                self.outcomesDict[monthDate] = outArray
                if (i == self.monthArray.count) {
                    PoliceAPI
                        .getCrimes(lat, long: lng)
                        .addObserver(self)
                        .addObserver(self.statusOverlay)
                        .load()
                }
                
                
            }.addObserver(self.statusOverlay).load()
            ++i
        }
        
    }
    
    func resourceChanged(resource: Resource, event: ResourceEvent) {
        crimesArray = []
        
        // If we have some new data
        if (resource.latestData != nil) {
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
            PoliceAPI.outcomesDict = self.outcomesDict
            PoliceAPI.crimesArray = crimesArray
            loadStatistics()
            resource.removeObservers(ownedBy: self)
        }
    }
    
    internal func crimeToDict(month: String,
            category: String) -> CrimeDict {
            
            var crimeDict = [String: AnyObject]()
            crimeDict["month"]       = month
            crimeDict["category"]    = category
                
            return crimeDict
    }
    
    internal func previousMonths(monthsToDeduct: Int, year: String, month: String)-> String {
        var yearNum = Int(year)!
        var monthNum = Int(month)!
        
        if (monthNum - monthsToDeduct < 1){
            --yearNum
            monthNum = (monthNum - monthsToDeduct) % 12
        }
        else {
            monthNum = monthNum - monthsToDeduct
        }
        
        return "\(yearNum)-\(monthNum)"
    }
    
    func loadStatistics(){
        nCrimes.text = String(self.crimesArray.count)
        
        var catDict = [String: Double]()
        for crime in crimesArray{
            if (catDict[String(crime["category"]!)] == nil){
                catDict[String(crime["category"]!)] = 1
            }
            else {
                catDict[String(crime["category"]!)]! += 1
            }
        }
        let sortedCat = catDict.keys.sort({ (firstKey, secondKey) -> Bool in
            return catDict[firstKey] > catDict[secondKey]
        })

        var topCatArray = [String]()
        if ( sortedCat.count > 3){
            topCatArray += sortedCat[0..<3]
        }
        else {
            topCatArray += sortedCat[0..<sortedCat.count]
        }
        var dataEntries: [ChartDataEntry] = []
        
        for var i = 0; i < topCatArray.count; ++i {
            let dataEntry = ChartDataEntry(value: catDict[sortedCat[i]]!, xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        let pieChartData = PieChartData(xVals: topCatArray, dataSet: pieChartDataSet)
        
        var colors: [UIColor] = []
        
        colors = [Style.flatRed3, Style.flatBlue5, Style.flatGold4]
        
        pieChartDataSet.colors = colors
        
        pieChartView.data = pieChartData
        pieChartData.setDrawValues(false)
        pieChartView.drawSliceTextEnabled = false
        pieChartView.holeColor = Style.viewBackground
        pieChartView.rotationWithTwoFingers = true
        pieChartView.animate(xAxisDuration: NSTimeInterval(5))
        pieChartView.legend.position = .RightOfChart
        pieChartView.legend.textColor = Style.fontColor
        pieChartView.descriptionText = ""
        pieChartView.backgroundColor = Style.viewBackground
        
        var numResolvedArr: [ChartDataEntry] = []
        
        var i = 0
        for month in monthArray {
            let dataEntry = ChartDataEntry(value: Double(outcomesDict[month]!.count), xIndex: i)
            numResolvedArr.append(dataEntry)
            ++i
        }
        
        let lineChartDataSet = LineChartDataSet(yVals: numResolvedArr)
        let lineChartData = LineChartData(xVals: monthArray, dataSet: lineChartDataSet)
        lineChartDataSet.circleColors = [Style.circleColor]
        lineChartDataSet.circleHoleColor = Style.white
        lineChartView.leftAxis.startAtZeroEnabled = false
        lineChartData.setDrawValues(false)
        lineChartView.data = lineChartData
        lineChartView.legend.enabled = false
        lineChartView.descriptionText = ""
        lineChartView.rightAxis.enabled = false
        lineChartView.xAxis.labelPosition = .Bottom
        lineChartView.leftAxis.xOffset = 9.0
        lineChartView.xAxis.labelTextColor = Style.fontColor
        lineChartView.xAxis.avoidFirstLastClippingEnabled = true
        lineChartView.leftAxis.labelTextColor = Style.fontColor
        lineChartView.animate(xAxisDuration: NSTimeInterval(4))
        lineChartView.backgroundColor = Style.viewBackground
        lineChartView.gridBackgroundColor = Style.viewBackground
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.axisLineColor = Style.fontColor
        lineChartView.leftAxis.axisLineColor = Style.fontColor


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openDrawer(sender: UIBarButtonItem) {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }

}

