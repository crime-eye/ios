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
    
    // Initialise variables used in the page
    let statusOverlay = ResourceStatusOverlay()
    
    typealias CrimeDict = Dictionary<String, AnyObject>
    var crimesArray: [CrimeDict] = []
    
    var childCrimeView: [ViewCrimesController] = []
    @IBOutlet weak var bottomBarView: UITextView!

    var MAPLAT: Double = PostcodesAPI.lat
    var MAPLONG: Double = PostcodesAPI.lng

    var locArray: [Location] = []
    
    var annotations = [String: RadiusAnnotation]()
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a rotation detection to use custom animations on rotation
        NSNotificationCenter.defaultCenter().addObserver(self, selector:
        "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        // Set style options for the page
        bottomBarView.backgroundColor = Style.viewBackground

        // load statistics in to map if data already exists
        if !self.annotations.isEmpty {
            dispatch_async(dispatch_get_global_queue(0, 0)){
                self.setupMapView()
            }
        }
        // If no crime data exists, make the api call to get it
        else {
            dispatch_async(dispatch_get_global_queue(0, 0)){
                self.getCrimes()
            }
        }
        
        // Set up basic map values on init
        setupMapView()
    }
    
    // Set up map view variables and initial location
    internal func setupMapView() {
        self.mapView.delegate = self
        self.mapView.mapType = .Standard
        self.mapView.pitchEnabled = false
        
        // Set the map region
        let location = CLLocationCoordinate2D(latitude: MAPLAT,
                                              longitude: MAPLONG)
        let region = MKCoordinateRegionMakeWithDistance(
                                              location, 1500.0, 1500.0)
        self.mapView.setRegion(region, animated: true)
    }
    
    // When the map finishes loading, get the crimes from the police API
    func getCrimes() {
        PoliceAPI
            .getCrimes(MAPLAT, long: MAPLONG)
            .addObserver(self)
            .loadIfNeeded()
    }

    // If the resouces from the API have changed
    func resourceChanged(resource: Resource, event: ResourceEvent) {
        // Get the updated information using the global queue
        dispatch_async(dispatch_get_global_queue(0, 0)) {

            if (resource.latestData != nil) {

                // Get the json array of crimes
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
                    // Check if crime outcome is null to get the correct string
                    if (outcome != "null") {
                        outcome =
                               crimes["outcome_status"]["category"].stringValue
                    }
                    
                    // Make a location object from each crime to be passed to
                    // the map annotations
                    let loc = Location(lat: lat,
                        lon: lng,
                        category: cat,
                        month: month,
                        street: street,
                        outcome: outcome)
                    
                    // Create a string identifier from the coordinate of the
                    // object
                    let coords = loc.coordinate
                    let coordString = String(loc.coordinate.latitude) + " " +
                        String(loc.coordinate.longitude)
                    // Check if the dict string exists, if not create a new
                    // annotation
                    if self.annotations[coordString] == nil {
                        self.annotations[coordString] = RadiusAnnotation(
                            coordinate: coords, location: loc)
                    }
                    // If the annotation does exist, add the crime to the
                    // existing list
                    if let val = self.annotations[coordString] {
                        val.addLocation(loc)
                    }
                }
                // Store the list of circle overlays and annotation pins
                var overlays = [MKCircle] ()
                var radiiPins = [RadiusAnnotation] ()
                
                // Loop over calculated annotations
                for annotation in self.annotations
                {
                    // Initialise overlays and set the colour
                    let overlay = MKCircle (centerCoordinate:
                        annotation.1.coordinate,
                        radius: (annotation.1.radiusSize))
                    let uicolor = annotation.1.colour
                    
                    overlay.accessibilityElements = [uicolor]
                    overlays.append(overlay)
                    radiiPins.append(annotation.1)
                }
                // Using the main thread for UI changes
                dispatch_async(dispatch_get_main_queue()) {
                    // Make sure all previous annotations have been removed
                    // from the map
                    let annotationsToRemove = self.mapView.annotations.filter
                        { $0 !== self.mapView.userLocation }
                    self.mapView.removeAnnotations( annotationsToRemove )
                    // Add all overlays and annotations
                    self.mapView.addOverlays(overlays)
                    self.mapView.addAnnotations(radiiPins)
                }
                // Remove API observers after call
                resource.removeObservers(ownedBy: self)
            }
        }
    }
    
    // If an annotation is clicked on the map
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation)
                                                          -> MKAnnotationView? {
        // Default check annotation type
        if !(annotation is RadiusAnnotation) {
            return nil
        }
        
        // Reuse annotation views so they don't have to be reinitialised
        // multiple times
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier("test")
        if anView == nil {
            // Initialise and allow callout to be shown
            anView = MKAnnotationView(annotation: annotation,
                                                        reuseIdentifier: "test")
            anView!.canShowCallout = true
        }
        // Or use previously initialised annotation
        else {
            anView!.annotation = annotation
        }
        // Get the annotation of the pin
        let cpa = annotation as? RadiusAnnotation
        // Hide default pin image so only the overlays are shown
        anView!.image = nil
        // Set the click radius as the size of the overlay radius
        anView!.frame = CGRectMake(0, 0,
            CGFloat(cpa!.radiusSize/1.5), CGFloat(cpa!.radiusSize/1.5))
        // Add a detail button for the user to click on
        anView!.rightCalloutAccessoryView = UIButton(
                            type: UIButtonType.DetailDisclosure) as UIButton
        
        return anView
    }
    
    // Overwrite the overlay function to render the circles properly
    func mapView(
        mapView: MKMapView, rendererForOverlay
        overlay: MKOverlay) -> MKOverlayRenderer {
        // Get the circle to be rendered and get the colour it needs to be
        let circle = overlay as! MKCircle
        let colour = circle.accessibilityElements?.first as! UIColor
        // Set the colour and line width and return the renderer
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = colour
        circleRenderer.lineWidth = 2
        circleRenderer.fillColor = UIColor(
                                red: 128, green: 128, blue: 128, alpha: 0.5)
        return circleRenderer
    }
    
    // If an annotation is clicked on the map
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
            // Get the annotation of the pin
            let annView = view.annotation as? RadiusAnnotation
            
            // Get the location of the clicked map pin and centre it in the
            // top half of the screen
            var center = annView?.coordinate;
            center!.latitude -= self.mapView.region.span.latitudeDelta * 0.25;
            self.mapView.setCenterCoordinate(center!, animated: false)
            
            // Make sure multiple crime info views aren't already open
            while childCrimeView.count > 0 {
                let vc = childCrimeView[0]
                vc.view.removeFromSuperview()
                childCrimeView.removeFirst()
            }
            // Initialise a crimes view
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier(
                "CrimesView") as? ViewCrimesController
            
            // Set the crime array in the view controller and animate it onto
            // the screen
            vc!.crimes = annView!.locArray
            animateCrimesView(vc!, duration: 0.5)
            childCrimeView.append(vc!)
    }
    
    @IBAction func filterCrimes(sender: AnyObject) {
    }
    
    // Function to allow the user to change postcode viewed on the map
    @IBAction func changePostcode(sender: AnyObject) {
        // Create alert to prompt user to enter postcode
        let alertController = UIAlertController(title: "Change postcode",
            message: "Please input a new postcode:", preferredStyle: .Alert)
        // Create the cancel action for the alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            (_) in }
        // Add text field to allow the postcode to be entered
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Enter postcode"
        }
        // Create the confirm postcode action, dealing with input cases
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default) {
            (_) in
            if let field = alertController.textFields![0] as? UITextField {
                if field.text!.isEmpty {
                    // If field is empty, show empty postcode entered alert
                    // If no postcode entered, present empty error
                    self.showAlert("Postcode Empty",
                              message: "Please enter a valid postcode",
                              buttonText: "OK", previousAlert: alertController)
                }
                // If something is entered, check the postcode for validity by
                // using the postcode API
                else {
                    // Validate entered postcode
                    PostcodesAPI.validatePostcode(field.text!).addObserver(
                                                                 owner: self) {
                        resource, event in
                        if case .NewData = event {
                            let valid = resource.json["result"]
                            // If the postcode is valid
                            if valid {
                                // Get the latitude and longitude of postcode
                                PostcodesAPI.postcodeToLatAndLng(field.text!)
                                                    .addObserver(owner: self) {
                                    resource2, event in
                                    if case .NewData = event {
                                        // Get results lat and long values
                                        let result = resource2.json["result"]
                                        self.MAPLAT = result["latitude"]
                                                                    .doubleValue
                                        self.MAPLONG = result["longitude"]
                                                                    .doubleValue
                                        // Remove any previous pins and overlays
                                        let annotationsToRemove =
                                            self.mapView.annotations.filter
                                            { $0 !== self.mapView.userLocation }
                                        let overlaysToRemove =
                                            self.mapView.overlays.filter
                                            { $0 !== self.mapView.userLocation }
                                        self.mapView.removeAnnotations(
                                                            annotationsToRemove)
                                        self.mapView.removeOverlays(
                                                               overlaysToRemove)
                                        // Update the map region
                                        let location = CLLocationCoordinate2D(
                                            latitude: self.MAPLAT,
                                            longitude: self.MAPLONG)
                                        let region =
                                            MKCoordinateRegionMakeWithDistance(
                                                      location, 1500.0, 1500.0)
                                        self.mapView.setRegion(
                                                      region, animated: true)
                                        // API calls after the map is moved
                                        }
                                }.addObserver(self.statusOverlay).load()
                            }
                            // If the postcode API returns incorrect
                            else {
                                // Show an appropriate error popup alert
                                self.showAlert("Invalid postcode",
                                    message: "Please enter a valid postcode",
                                    buttonText: "OK",
                                    previousAlert: alertController)
                            }
                        }
                    }.addObserver(self.statusOverlay).load()
                }
            }
        }
        // Add the actions to the main enter postcode alert and show to screen
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true,
                                                    completion: nil)
    }
    
    // Show popup alert to screen with basic cancel action
    func showAlert(alertTitle: String, message: String, buttonText: String,
        previousAlert: UIAlertController) {
        // Create alert
        let alert = UIAlertController(title: alertTitle, message: message,
            preferredStyle: .Alert)
        
        // Create cancel action going back to main enter postcode alert
        let cancelEmptyAction = UIAlertAction(title: "OK", style: .Cancel) {
            (_) in
            self.presentViewController(previousAlert, animated: true,
                                       completion: nil)
        }
        // Add action and show alert to screen
        alert.addAction(cancelEmptyAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // If the device has been rotated, make some UI changes
    func rotated()
    {
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
        {
            // Readjust centre of selected area when rotated
            var center = self.mapView.centerCoordinate;
            center.latitude += self.mapView.region.span.latitudeDelta * 0.13;
            self.mapView.setCenterCoordinate(center, animated: true)
            // Readjust position of view crimes list so it fits nicely
            if childCrimeView.count != 0 {
                let vc = childCrimeView[0]

                if vc.SHOWVIEW == true {
                    animateCrimesView(vc, duration: 0)
                }
                else {
                    childCrimeView.removeFirst()
                }
            }
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
        {
            // Readjust centre of selected area when rotated
            var center = self.mapView.centerCoordinate;
            center.latitude -= self.mapView.region.span.latitudeDelta * 0.14;
            self.mapView.setCenterCoordinate(center, animated: true)
            // Readjust position of view crimes list so it fits nicely
            if childCrimeView.count != 0 {
                let vc = childCrimeView[0]
                if vc.SHOWVIEW == true {
                    animateCrimesView(vc, duration: 0)
                }
                else {
                    childCrimeView.removeFirst()
                }
            }

        }
        
    }
    
    // Show crime view table sliding up from the bottom to halfway up the screen
    func animateCrimesView(vc: ViewCrimesController, duration: Double) {
        let bottomY = UIScreen.mainScreen().bounds.height
        // Set the frame of the view to be half the screen in height
        vc.view.frame = CGRectMake(0, bottomY, self.view.frame.size.width,
                                                self.view.frame.size.height/2);
        // Attach to mapview as subview
        self.addChildViewController(vc)
        self.view.addSubview(vc.view)
        vc.didMoveToParentViewController(self)
        // Animate upwards from the bottom using the specified duration
        UIView.animateWithDuration(duration, animations: {
            vc.view.frame = CGRectMake(0,
                bottomY - self.view.frame.size.height/2,
                self.view.frame.size.width, self.view.frame.size.height/2)})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Function to access the app drawer and open it from the crimes page
    @IBAction func openDrawer(sender: UIBarButtonItem) {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate
            as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left,
            animated: true, completion: nil)
    }

}