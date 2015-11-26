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

    var menuItems:[String] = ["Home","Crime","Neighbourhood","Stop and Search"];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.translucent = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return menuItems.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
        
    {
        let mycell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as! CustomTableViewCell
        mycell.menuLabelText.text = menuItems[indexPath.row]
        return mycell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        switch(indexPath.row)
        {
        case 0:
            let mainController = self.storyboard?.instantiateViewControllerWithIdentifier("MainController") as! MainController
            let mainNavController = UINavigationController(rootViewController: mainController)
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.centerContainer!.centerViewController = mainNavController
            appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            
            break;
            
        case 1:
            let crimeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
            let crimeNavController = UINavigationController(rootViewController: crimeViewController)
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.centerContainer!.centerViewController = crimeNavController
            appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            
            break;
            
        case 2:
            let neighbourController = self.storyboard?.instantiateViewControllerWithIdentifier("NeighbourhoodController") as! NeighbourhoodController
            let neighbourNavController = UINavigationController(rootViewController: neighbourController)
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.centerContainer!.centerViewController = neighbourNavController
            appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            
            break;
            
        case 3:
            let searchController = self.storyboard?.instantiateViewControllerWithIdentifier("SearchController") as! SearchController
            let searchNavController = UINavigationController(rootViewController: searchController)
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.centerContainer!.centerViewController = searchNavController
            appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            
            break;
            
        default:
            print("\(menuItems[indexPath.row]) is selected")
            
        }
    }

}
