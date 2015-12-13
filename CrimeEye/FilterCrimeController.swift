//
//  FilterCrimeControllerTableViewController.swift
//  CrimeEye
//
//  Created by Kieran Haden on 13/12/2015.
//  Copyright © 2015 Crime Eye. All rights reserved.
//

import UIKit

class FilterCrimeController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var SHOWVIEW = true
    
    @IBOutlet weak var streetLabel: UILabel!
    
    var selectedValue = "None"
    
    let crimeList = ["anti-social-behaviour", "bicycle-theft", "burglary", "criminal-damage-arson", "drugs", "other-crime", "other-theft", "possession-of-weapons", "public-order", "robbery", "shoplifting", "theft-from-the-person", "vehicle-crime", "vehicle-theft", "violent-crime"]
    let categoryList = ["None", "Anti-social Behaviour", "Bicycle Theft", "Burglary", "Criminal Damage Arson", "Drugs", "Other Crime", "Other Theft", "Possession of Weapons", "Public Order", "Robbery", "Shoplifting", "Theft from the Person", "Vehicle Crime", "Vehicle Theft", "Violent Crime"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 20;
        view.layer.masksToBounds = true;
                
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return crimeList.count;
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            let mycell = tableView
                .dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath)
                as! CustomTableViewCell
            
            mycell.filterText.text = categoryList[indexPath.row]
            mycell.filterText.textColor = UIColor.blackColor()
            
            return mycell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow
        
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!) as! CustomTableViewCell
        
        selectedValue = currentCell.filterText!.text!
    }
    
    @IBAction func cancelFilter(sender: UIButton) {
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
    }
    
    @IBAction func confirmSelection(sender: UIButton) {
        let parent = self.parentViewController as? MapViewController
        parent?.confirmFilter(selectedValue)
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
