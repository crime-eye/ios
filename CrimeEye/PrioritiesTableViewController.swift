//
//  PrioritiesTableViewController.swift
//  CrimeEye
//
//  Created by Gurpreet Paul on 12/12/2015.
//  Copyright © 2015 Crime Eye. All rights reserved.
//

import UIKit
import Siesta
import SwiftyJSON
import SwiftDate

class PrioritiesTableViewController: UITableViewController, ResourceObserver {
    

    var lat = 0.0
    var lng = 0.0
    
    /// A list of Prioritys will be populated
    /// when the relevant call to the API is made
    var prioritiesList = [Priority]()
    
    /// Stores the user's neighbourhood
    var neighbourhood: Resource? {
        didSet {
            oldValue?.removeObservers(ownedBy: self)
            neighbourhood?.addObserver(self).loadIfNeeded()
        }
    }
    
    
    /// Priorities of the neighbourhood team
    var priorities: Resource? {
        didSet {
            oldValue?.removeObservers(ownedBy: self)
            priorities?.addObserver(self).loadIfNeeded()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Style.viewBackground
        
        // Auto set the tableview's cells height
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60.0
        
        // Need a handle on the coords
        self.lat = Store.defaults.doubleForKey(Store.LAT)
        self.lng = Store.defaults.doubleForKey(Store.LONG)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        // Make our first API call to find the user's
        // neighbourhood now.
        neighbourhood = PoliceAPI.locateNeighbourhood(lat, lng: lng)
    }
    
    /**
     If the neighbourhood resource is populated, then we can 
     make the call to the API
     */
    internal func getPrioritiesFromAPI() {
        if let force = neighbourhood?.json["force"].stringValue,
                nCode = neighbourhood?.json["neighbourhood"].stringValue {
            priorities =
                PoliceAPI.getPriorities(force, neighbourhoodCode: nCode)
        }
    }
    
    /**
     Get a list of Prioritys given a list of JSON dictionaries.
     - parameters:
        - items: The list of dictionary based JSON priorities.
     - returns: An array of Prioritys.
     */
    internal func getListOfPriorities(items: [JSON]) -> [Priority] {
        var prioritiesArray = [Priority]()
        for item in items {
            let ad      = item["action-date"].stringValue
            let action  = item["action"].stringValue
            let issue   = item["issue"].stringValue
            
            let priority = Priority(actionDate: ad, issue: issue, action: action)
            prioritiesArray.append(priority)
        }
        return prioritiesArray
    }
    
    
    // Has the resource changed, called as part of ResourceObserver
    func resourceChanged(resource: Resource, event: ResourceEvent) {
        
        // First check if we have the correct neighbourhood
        // details
        if neighbourhood?.latestData != nil {
            if case .NewData = event {
                // If we have new data then let's get some
                // new priorities too
                getPrioritiesFromAPI()
            }
        }
        
        // Otherwise we can now use the latest data from
        // priorities to obtain a list of priorities
        if priorities?.latestData != nil {
            if let items = priorities!.json.array {
                self.prioritiesList = getListOfPriorities(items)
            }
        }
        
        tableView.reloadData()
    }
    
    /**
     Removes any HTML tags from a string.
     - parameters:
     - s: HTML loaded string.
     - returns: HTML free string.
     */
    internal func removeTags(s: String) -> String {
        return s.stringByReplacingOccurrencesOfString("<[^>]+>",
            withString: "",
            options: .RegularExpressionSearch,
            range: nil)
    }
    
    /**
     Returns a String that has the month and the year in.
     - parameters:
     - dateString: The full date string in (nearly) ISO8601 format.
     - returns: A monthname and a year.
     */
    internal func toYearAndMonth(dateString: String) -> String {
        let date = dateString.toDate(DateFormat.Custom("yyyy-MM-dd'T'HH:mm:ss"))
        return "\(date!.monthName) \(date!.year)"
    }

    // Number of sections in table is 1
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // Number of list items
    override func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int)
        -> Int {
        return prioritiesList.count
    }

    // Cast it to the custom cell then set the UILabels
    // within that cell
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath index: NSIndexPath)
        -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("PriorityCell")
                 as! PrioritiesCell

            let priority: Priority = prioritiesList[index.row]
            cell.date.text = toYearAndMonth(priority.actionDate)
            cell.issue.text = removeTags(priority.issue)
            cell.action.text = ""

            return cell
    }

    override func viewWillDisappear(animated: Bool) {
        neighbourhood?.invalidate()
        neighbourhood?.removeObservers(ownedBy: self)
        priorities?.removeObservers(ownedBy: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
