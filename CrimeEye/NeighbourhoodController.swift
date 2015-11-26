//
//  NeighbourhoodController.swift
//  CrimeEye
//
//  Created by Kieran Haden on 26/11/2015.
//  Copyright © 2015 Gurpreet Paul. All rights reserved.
//

import UIKit
import MMDrawerController

class NeighbourhoodController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
