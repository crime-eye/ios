//
//  ViewCrimesControllerViewController.swift
//  CrimeEye
//
//  Created by Kieran Haden on 09/12/2015.
//  Copyright © 2015 Crime Eye. All rights reserved.
//

import UIKit

class ViewCrimesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var SHOWVIEW = true
    
    @IBOutlet weak var streetLabel: UILabel!
    // Menu items to display
    var crimes: [Location]?

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.navigationBar.translucent = false;
        
        mainView.backgroundColor = Style.viewBackground
        tableView.backgroundColor = Style.viewBackground
        
        streetLabel.text = crimes![0].street
        streetLabel.adjustsFontSizeToFitWidth = true
        streetLabel.textColor = Style.fontColor
        streetLabel.backgroundColor = Style.viewBackground
    }
    
    @IBAction func closeWindow(sender: UIButton) {
        SHOWVIEW = false
        self.view.removeFromSuperview()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return crimes!.count;
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
        let mycell = tableView
            .dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath)
            as! CustomTableViewCell
        
        let crimeList = ["anti-social-behaviour", "bicycle-theft", "burglary", "criminal-damage-arson", "drugs", "other-crime", "other-theft", "possession-of-weapons", "public-order", "robbery", "shoplifting", "theft-from-the-person", "vehicle-crime", "vehicle-theft", "violent-crime"]
        let categoryList = ["Anti-social Behaviour", "Bicycle Theft", "Burglary", "Criminal Damage Arson", "Drugs", "Other Crime", "Other Theft", "Possession of Weapons", "Public Order", "Robbery", "Shoplifting", "Theft from the Person", "Vehicle Crime", "Vehicle Theft", "Violent Crime"]
        let imageList = ["AntiSocial", "Bicycle", "Burglary", "Arson", "Drugs", "Violence", "Violence", "WeaponPossession", "PublicOrder", "Robbery", "Robbery", "PersonTheft", "CarTheft", "CarTheft", "Violence"]
            
        let i = crimeList.indexOf(crimes![indexPath.row].category!)
        mycell.CrimeText.text = categoryList[i!]
        mycell.crimeIcon.image = UIImage(named: imageList[i!])
        mycell.actionTakenText.text = crimes![indexPath.row].outcome
        mycell.actionTakenText.backgroundColor = Style.viewBackground
        if (crimes![indexPath.row].outcome == ""){
            mycell.actionTakenText.text = "No outcome taken as of yet"
        }
        mycell.actionTakenText.textColor = Style.fontColor
        mycell.crimeIcon.tintColor = UIColor.whiteColor()
        mycell.backgroundColor = Style.viewBackground
            
        return mycell;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
