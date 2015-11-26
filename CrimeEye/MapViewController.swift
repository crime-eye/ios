//
//  MapViewController.swift
//  CrimeEye
//
//  Created by Khen Cruzat on 22/11/2015.
//  Copyright © 2015 Gurpreet Paul. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import Foundation
import MMDrawerController

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getLocation(postCode: String, completionHandler: (String, String) -> ()){

        
    }
    

    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .Standard
            mapView.pitchEnabled = false
            getLocation ("LS29JT", completionHandler: { (latitude, longitude) in
                let location = CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!)
                let region = MKCoordinateRegionMakeWithDistance(location, 200.0, 200.0)
                self.mapView.setRegion(region, animated: true)
            })
        }
    }
    
    @IBAction func openDrawer(sender: UIBarButtonItem) {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }

}
