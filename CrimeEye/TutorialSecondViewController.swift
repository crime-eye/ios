//
//  TutorialSecondViewController.swift
//  CrimeEye
//
//  Created by Gurpreet Paul on 03/12/2015.
//  Copyright © 2015 Crime Eye. All rights reserved.
//

import UIKit

class TutorialSecondViewController: UIViewController {

    
    @IBOutlet var gpsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchChanged(sender: UISwitch) {
        if gpsSwitch.on {
            Store.defaults.setBool(true, forKey: Store.USE_GPS)
        } else {
            Store.defaults.setBool(false, forKey: Store.USE_GPS)
        }
    }

    @IBAction func clickedOK(sender: UIButton) {
        Store.defaults.setBool(true, forKey: Store.IS_FIRST_LOAD)
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        app.loadMainView()
    }
    

}
