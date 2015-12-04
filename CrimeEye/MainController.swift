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
    var crimesArray: [CrimeDict] = []
    
    // MARK: Outlets
    @IBOutlet weak var nCrimes: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = Style.viewBackground
        nCrimes.textColor = Style.flatGold2
        pieChartView.backgroundColor = Style.viewBackground
    }
    
    func loadData() {
        let lat = PostcodesAPI.lat
        let lng = PostcodesAPI.lng
        if (PostcodesAPI.lat == 0.0){
            PostcodesAPI.postcodeToLatAndLng("LS2 9JT").addObserver(owner: self) {
                resource, event in
                if case .NewData = event {
                    let result = resource.json["result"]
                    PostcodesAPI.lat = result["latitude"].doubleValue
                    PostcodesAPI.lng = result["longitude"].doubleValue
                    
                    PoliceAPI
                        .getCrimes(PostcodesAPI.lat, long: PostcodesAPI.lng)
                        .addObserver(self)
                        .loadIfNeeded()
                }
                }.load()
        }
        else {
            PoliceAPI
                .getCrimes(lat, long: lng)
                .addObserver(self)
                .loadIfNeeded()
        }
        
    }
    
    func resourceChanged(resource: Resource, event: ResourceEvent) {
        // If we have some new data
        if (resource.latestData != nil) {
            let jsonArray = resource.json
            
            // iterate over all the crimes
            for (_, crimes) in jsonArray {
                
                let crimeLoc = crimes["location"]
                
                let month       = crimes["month"].stringValue
                let cat         = crimes["category"].stringValue
                let lat         = crimeLoc["latitude"].doubleValue
                let lng         = crimeLoc["longitude"].doubleValue
                let street      = crimeLoc["street"]["name"].stringValue
                
                
                // store information on each crime
                let crimeDict = self.crimeToDict(month,
                    category: cat,
                    lat: lat,
                    lng: lng,
                    street: street)
                
                self.crimesArray.append(crimeDict)
                
                resource.removeObservers(ownedBy: self)
            }
            nCrimes.text = String(self.crimesArray.count)
            loadStatistics()
        }
    }
    
    internal func crimeToDict(month: String,
        category: String,
        lat: Double,
        lng: Double,
        street: String) -> CrimeDict {
            
            var crimeDict = [String: AnyObject]()
            crimeDict["month"]       = month
            crimeDict["category"]    = category
            crimeDict["latitude"]    = lat
            crimeDict["longitude"]   = lng
            crimeDict["street"]      = street
            
            return crimeDict
    }
    
    func loadStatistics(){
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
        topCatArray += sortedCat[0..<3]
        var dataEntries: [ChartDataEntry] = []
        
        for var i = 0; i < topCatArray.count; ++i {
            let dataEntry = ChartDataEntry(value: catDict[sortedCat[i]]!, xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        let pieChartData = PieChartData(xVals: topCatArray, dataSet: pieChartDataSet)
        
        var colors: [UIColor] = []
        
        colors = [Style.flatRed1, Style.white, Style.flatGold2]
        
        pieChartDataSet.colors = colors
        
        pieChartView.data = pieChartData
        pieChartData.setDrawValues(false)
        pieChartView.drawSliceTextEnabled = false
        pieChartView.holeTransparent = true
        pieChartView.holeAlpha = 0
        pieChartView.animate(xAxisDuration: NSTimeInterval(5))
        pieChartView.legend.position = .RightOfChartInside
        pieChartView.legend.textColor = Style.white
        pieChartView.descriptionText = ""
        pieChartView.center = CGPointMake(0, pieChartView.center.y)

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

