//
//  DrawerController.swift
//  CrimeEye
//
//  Created by Kieran Haden on 26/11/2015.
//  Copyright © 2015 Gurpreet Paul. All rights reserved.
//

import UIKit
import MMDrawerController

class DrawerController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var lastSelected = 0
    
    // Menu items to display
    var menuItems: [String] = ["Home", "Crime", "Neighbourhood", "Stop and Search"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.translucent = false;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count;
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
        let mycell = tableView
            .dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath)
            as! CustomTableViewCell
        
        mycell.menuLabelText.text = menuItems[indexPath.row]
        return mycell;
    }
    
    // Controls what to swap in and out of the center container
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Only switch to controllers if we're not selected
        if (lastSelected != indexPath.row) {
            switch (indexPath.row) {
                case 0:
                    switchTo("MainController")
                    break;
                    
                case 1:
                    switchTo("MapViewController")
                    break;
                    
                case 2:
                    switchTo("NeighbourhoodController")
                    break;
                    
                case 3:
                    switchTo("SearchController")
                    break;
                    
                default:
                    print("Error: Could not find controller. " +
                        "\(menuItems[indexPath.row]) is selected.")
            }
            
        } else { closeDrawer() }
        
        lastSelected = indexPath.row
    }
    
    // Switches to a view controller given a name
    internal func switchTo(controllerName: String) {
        // Downcast to UIViewController
        let c = (self.storyboard?.instantiateViewControllerWithIdentifier(controllerName))! as UIViewController
        let mainNavController = UINavigationController(rootViewController: c)
        getAppDelegate().centerContainer!.centerViewController = mainNavController
        closeDrawer()
    }
    
    
    internal func closeDrawer() {
        getAppDelegate().centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    func getAppDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
