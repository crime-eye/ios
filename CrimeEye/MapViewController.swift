//
//  MapViewController.swift
//  CrimeEye
//
//  Created by Khen Cruzat on 22/11/2015.
//  Copyright © 2015 Gurpreet Paul. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import MMDrawerController
import Siesta

class MapViewController: UIViewController, MKMapViewDelegate, ResourceObserver,
UIGestureRecognizerDelegate{
    
    let statusOverlay = ResourceStatusOverlay()

    
    
    typealias CrimeDict = Dictionary<String, AnyObject>
    var crimesArray: [CrimeDict] = []
    
    var childCrimeView: [ViewCrimesController] = []
    @IBOutlet weak var bottomBarView: UITextView!

    var MAPLAT: Double = PostcodesAPI.lat
    var MAPLONG: Double = PostcodesAPI.lng

    var locArray: [Location] = []
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        bottomBarView.backgroundColor = Style.viewBackground

        setupMapView()
    }
    
    internal func setupMapView() {
        self.mapView.delegate = self
        self.mapView.mapType = .Standard
        self.mapView.pitchEnabled = false
        
        
        
        // Set the map region
        let location = CLLocationCoordinate2D(latitude: MAPLAT, longitude: MAPLONG)
        let region = MKCoordinateRegionMakeWithDistance(location, 1500.0, 1500.0)
        self.mapView.setRegion(region, animated: true)
    }
    
    // If the map has finished loading....
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        
        PoliceAPI
            .getCrimes(MAPLAT, long: MAPLONG)
            .addObserver(self)
            .loadIfNeeded()
    }

    
    func resourceChanged(resource: Resource, event: ResourceEvent) {

        dispatch_async(dispatch_get_global_queue(0, 0)) {

            if (resource.latestData != nil) {
                
                var annotations = [String: RadiusAnnotation]();

                let jsonArray = resource.json
                
                
                // iterate over all the crimes
                for (_, crimes) in jsonArray {
                    
                    let crimeLoc = crimes["location"]
                    
                    let month       = crimes["month"].stringValue
                    let cat         = crimes["category"].stringValue
                    let lat         = crimeLoc["latitude"].doubleValue
                    let lng         = crimeLoc["longitude"].doubleValue
                    let street      = crimeLoc["street"]["name"].stringValue
                    var outcome =
                        crimes["outcome_status"].stringValue
                    if (outcome != "null") {
                        outcome = crimes["outcome_status"]["category"].stringValue
                    }
                    
                    let loc = Location(lat: lat,
                        lon: lng,
                        category: cat,
                        month: month,
                        street: street,
                        outcome: outcome)
                    
                    let coords = loc.coordinate
                    let coordString = String(loc.coordinate.latitude) + " " +
                        String(loc.coordinate.longitude)
                    
                    if annotations[coordString] == nil {
                        annotations[coordString] = RadiusAnnotation(coordinate: coords,
                            location: loc)
                    }
                    if let val = annotations[coordString] {
                        val.addLocation(loc)
                    }
                }
                var overlays = [MKCircle] ()
                var radiiPins = [RadiusAnnotation] ()

                for annotation in annotations
                {
                    let overlay = MKCircle (centerCoordinate: annotation.1.coordinate,
                        radius: (annotation.1.radiusSize))
                    let uicolor = annotation.1.colour
                    
                    overlay.accessibilityElements = [uicolor]
                    overlays.append(overlay)
                    radiiPins.append(annotation.1)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    
                    let annotationsToRemove = self.mapView.annotations.filter
                        { $0 !== self.mapView.userLocation }
                    self.mapView.removeAnnotations( annotationsToRemove )

                    self.mapView.addOverlays(overlays)
                    self.mapView.addAnnotations(radiiPins)

                }
                resource.removeObservers(ownedBy: self)
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is RadiusAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        
        let cpa = annotation as? RadiusAnnotation
        anView!.image = nil
        anView!.frame = CGRectMake(0, 0,
            CGFloat(cpa!.radiusSize/1.5), CGFloat(cpa!.radiusSize/1.5))
        anView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure) as UIButton
        
        return anView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
            //performSegueWithIdentifier("View Crimes", sender: view)
            let annView = view.annotation as? RadiusAnnotation
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("CrimesView") as? ViewCrimesController
            
            vc!.crimes = annView!.locArray
            let bottomY = UIScreen.mainScreen().bounds.height
            vc!.view.frame = CGRectMake(0, bottomY, self.view.frame.size.width, self.view.frame.size.height/2);
            self.addChildViewController(vc!)
            self.view.addSubview(vc!.view)
            vc!.didMoveToParentViewController(self)
            
            UIView.animateWithDuration(0.5, animations: {
                vc!.view.frame = CGRectMake(0, bottomY - self.view.frame.size.height/2,
                    self.view.frame.size.width, self.view.frame.size.height/2)})
            
            childCrimeView.append(vc!)
    }
    
    @IBAction func filterCrimes(sender: AnyObject) {
    }
    
    @IBAction func changePostcode(sender: AnyObject) {
        print("user wants to change postcode")
        let alertController = UIAlertController(title: "Change postcode", message: "Please input a new postcode:", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Enter postcode"
        }
        
        
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                if (field.text!.isEmpty){
                    let emptyAlert = UIAlertController(title: "Postcode Empty", message: "Please enter a valid postcode.", preferredStyle: .Alert)
                    
                    let cancelEmptyAction = UIAlertAction(title: "OK", style: .Cancel) { (_) in
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    emptyAlert.addAction(cancelEmptyAction)
                    
                    
                    self.presentViewController(emptyAlert, animated: true, completion: nil)
                }
                else {
                    PostcodesAPI.validatePostcode(field.text!).addObserver(owner: self) {
                        resource, event in
                        if case .NewData = event {
                            let valid = resource.json["result"]
                            if valid {
                                Store.defaults.setBool(true, forKey: Store.IS_FIRST_LOAD)
                                PostcodesAPI.postcodeToLatAndLng(field.text!).addObserver(owner: self) {
                                    resource2, event in
                                    if case .NewData = event {
                                        let result = resource2.json["result"]
                                        self.MAPLAT = result["latitude"].doubleValue
                                        self.MAPLONG = result["longitude"].doubleValue
                                        
                                        PostcodesAPI.getPostcode(self.MAPLAT, lng: self.MAPLONG).addObserver(owner: self) {
                                            resource3, event in
                                            if case .NewData = event {
                                                let result = resource3.json["result"]
                                                //let newPostcode = result[0]["postcode"].stringValue
                                                
                                                // Set the map region
                                                let location = CLLocationCoordinate2D(latitude: self.MAPLAT, longitude: self.MAPLONG)
                                                let region = MKCoordinateRegionMakeWithDistance(location, 1500.0, 1500.0)
                                                self.mapView.setRegion(region, animated: true)
                                            }
                                            }.addObserver(self.statusOverlay).load()
                                        
                                    }
                                    }.addObserver(self.statusOverlay).load()
                            }
                            else {
                                let invalidController = UIAlertController(title: "Invalid Postcode", message: "Please enter a valid postcode.", preferredStyle: .Alert)
                                
                                let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (_) in
                                    self.presentViewController(alertController, animated: true, completion: nil)
                                }
                                invalidController.addAction(cancelAction)
                                
                                self.presentViewController(invalidController, animated: true, completion: nil)
                            }
                        }
                    }.addObserver(self.statusOverlay).load()
                }
            }
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func rotated()
    {
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
        {
            if childCrimeView.count != 0 {
                while childCrimeView.count > 1 {
                    childCrimeView.removeFirst()
                }
                let vc = childCrimeView[0]
                let bottomY = UIScreen.mainScreen().bounds.height
                vc.view.frame = CGRectMake(0, bottomY, self.view.frame.size.width, self.view.frame.size.height/2);
                self.addChildViewController(vc)
                self.view.addSubview(vc.view)
                vc.didMoveToParentViewController(self)
                
                UIView.animateWithDuration(0.0, animations: {
                    vc.view.frame = CGRectMake(0, bottomY - self.view.frame.size.height/2,
                        self.view.frame.size.width, self.view.frame.size.height/2)})
                
            }
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
        {
            if childCrimeView.count != 0 {
                while childCrimeView.count > 1 {
                    childCrimeView.removeFirst()
                }
                let vc = childCrimeView[0]
                let bottomY = UIScreen.mainScreen().bounds.height
                vc.view.frame = CGRectMake(0, bottomY, self.view.frame.size.width, self.view.frame.size.height/2);
                self.addChildViewController(vc)
                self.view.addSubview(vc.view)
                vc.didMoveToParentViewController(self)
                
                UIView.animateWithDuration(0.0, animations: {
                    vc.view.frame = CGRectMake(0, bottomY - self.view.frame.size.height/2,
                        self.view.frame.size.width, self.view.frame.size.height/2)})
                
            }
        }
        
    }
    
    func mapView(
        mapView: MKMapView, rendererForOverlay
        overlay: MKOverlay) -> MKOverlayRenderer {
            
            let circle = overlay as! MKCircle
            let colour = circle.accessibilityElements?.first as! UIColor
            
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.strokeColor = colour
            circleRenderer.lineWidth = 2
            circleRenderer.fillColor = UIColor(red: 128, green: 128, blue: 128, alpha: 0.5)
            return circleRenderer
    }
    
    internal func crimeToDict(month: String,
                    category: String,
                    lat: Double,
                    lng: Double,
                    street: String) -> CrimeDict {
            
        var crimeDict = [String: AnyObject]()
        crimeDict["month"]       = month
        crimeDict["category"]    = category
        crimeDict["latitude"]    = lat
        crimeDict["longitude"]   = lng
        crimeDict["street"]      = street
        
        return crimeDict
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func openDrawer(sender: UIBarButtonItem) {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }

}

class HalfSizePresentationController : UIPresentationController {
    override func frameOfPresentedViewInContainerView() -> CGRect {
        return CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height/2)
    }
}
