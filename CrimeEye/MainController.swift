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

class MainController: UIViewController, ResourceObserver {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = Style.viewBackground
        
        // GET last updated in a closure
        PoliceAPI.lastUpdated.addObserver(owner: self, closure: {resource, event in
                if (resource.latestData != nil) {
                    print(resource.json["date"])
                }
        }).loadIfNeeded()
        
        // GET last updated in this class' resourceChanged
        // PoliceAPI.lastUpdated.addObserver(self).loadIfNeeded()
    }
    
    
    func resourceChanged(resource: Resource, event: ResourceEvent) {
        // If we have some new data, then print
        // the date field out
        if (resource.latestData != nil) {
            print(resource.json["date"])
        }
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

