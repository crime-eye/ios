//
//  MapViewController.swift
//  CrimeEye
//
//  Created by Khen Cruzat on 22/11/2015.
//  Copyright © 2015 Gurpreet Paul. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import Foundation

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
        let endpoint = "http://api.postcodes.io/postcodes/"+postCode
        var long = ""
        var lat = ""
        Alamofire.request(.GET, endpoint)
            .responseJSON { response in
                guard response.result.error == nil else {
                    print("error in getting postcode info")
                    print(response.result.error!)
                    return
                }
        
                if let value: AnyObject = response.result.value {
                    let post = JSON(value)
                    let result = post["result"]
                    lat =  result["latitude"].rawString()!
                    long = result["longitude"].rawString()!
                    completionHandler(lat, long)
                }
        }
        
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

}
