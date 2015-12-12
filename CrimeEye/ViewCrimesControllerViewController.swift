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
    
    @IBOutlet weak var streetLabel: UILabel!
    // Menu items to display
    var crimes: [Location]?

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.navigationBar.translucent = false;
        
        mainView.backgroundColor = Style.viewBackground
        tableView.backgroundColor = Style.viewBackground
        
        streetLabel.text = crimes![0].street
        streetLabel.textColor = Style.sectionHeaders
        streetLabel.backgroundColor = Style.viewBackground
    }
    
    @IBAction func closeWindow(sender: UIButton) {
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
        
        let crimeList = ["anti-social-behaviour", "bicycle-theft", "burglary", "criminal-damage-arson", "drugs", "other-crime", "other-theft", "public-order", "robbery", "shoplifting", "theft-from-the-person", "vehicle-crime", "vehicle-theft", "violent-crime"]
        let categoryList = ["Anti-social Behaviour", "Bicycle Theft", "Burglary", "Criminal Damage Arson", "Drugs", "Other Crime", "Other Theft", "Public Order", "Robbery", "Shoplifting", "Theft from the Person", "Vehicle Crime", "Vehicle Theft", "Violent Crime"]
        let imageList = ["AntiSocial", "Bicycle", "Burglary", "Arson", "Drugs", "Violence", "Violence", "PublicOrder", "Robbery", "Robbery", "PersonTheft", "CarTheft", "CarTheft", "Violence"]
        let colourList = [UIColor.blueColor(), UIColor.greenColor(), UIColor.redColor(), UIColor.cyanColor(), UIColor.darkGrayColor(), UIColor.yellowColor(), UIColor.flatForestGreenColor(), UIColor.flatLimeColor(), UIColor.flatOrangeColor(), UIColor.flatPinkColor(), UIColor.flatPurpleColor(),
                UIColor.flatPlumColor(),
                UIColor.flatPowderBlueColor(), UIColor.flatSandColor()]
            
        let i = crimeList.indexOf(crimes![indexPath.row].category!)
        mycell.CrimeText.text = categoryList[i!]
        mycell.crimeIcon.image = UIImage(named: imageList[i!])
        mycell.actionTakenText.text = crimes![indexPath.row].outcome
        if (crimes![indexPath.row].outcome == ""){
            mycell.actionTakenText.text = "No outcome taken as of yet"
        }
        mycell.crimeIcon.tintColor = colourList[i!]
        mycell.backgroundColor = Style.viewBackground
            
        return mycell;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
