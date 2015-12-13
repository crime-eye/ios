//
//  NeighbourhoodController.swift
//  CrimeEye
//
//  Created by Gurpreet Paul on 12/12/2015.
//  Copyright © 2015 Crime Eye. All rights reserved.
//

import UIKit
import MMDrawerController

class NeighbourhoodController: UIViewController {

    @IBOutlet weak var container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let sboard = UIStoryboard(name: "Neighbourhood", bundle: nil)
        let vc = sboard.instantiateViewControllerWithIdentifier("TabBarController")
        
        // Notify the controller that we have a child view
        self.addChildViewController(vc)
        
        // Adjust sizes
        vc.view.frame = CGRectMake(0,
            0,
            self.container.frame.size.width,
            self.container.frame.size.height);
        
        // Add the vc to the container
        self.container.addSubview(vc.view)
        
        // Register the parent view controller
        vc.didMoveToParentViewController(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func openDrawer(sender: UIBarButtonItem) {
        let appD = UIApplication.sharedApplication().delegate as! AppDelegate
        appD.centerContainer!.toggleDrawerSide(MMDrawerSide.Left,
            animated: true,
            completion: nil)
    }

}
