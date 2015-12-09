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
                         UIPickerViewDelegate, UIPickerViewDataSource {
    
    typealias CrimeDict = Dictionary<String, AnyObject>
    var crimesArray: [CrimeDict] = []
    
    @IBOutlet weak var picker: UIPickerView!
    var pickerData: [String] = [String]()

    var locArray: [Location] = []
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerData = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6"]

        setupMapView()
    }
    
    internal func setupMapView() {
        self.mapView.delegate = self
        self.mapView.mapType = .Standard
        self.mapView.pitchEnabled = false
        
        let lat = PostcodesAPI.lat
        let lng = PostcodesAPI.lng
        
        // Set the map region
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let region = MKCoordinateRegionMakeWithDistance(location, 1500.0, 1500.0)
        self.mapView.setRegion(region, animated: true)
    }
    
    // If the map has finished loading....
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
    
        let lat = PostcodesAPI.lat
        let lng = PostcodesAPI.lng
        
        PoliceAPI
            .getCrimes(lat, long: lng)
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
                    
                    let loc = Location(lat: lat,
                        lon: lng,
                        category: cat,
                        month: month,
                        street: street)
                    
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

                    self.mapView.addOverlays(overlays)
                    self.mapView.addAnnotations(radiiPins)

                }
                
                resource.removeObservers(ownedBy: self)

                
            }
                    
         }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
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
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
        calloutAccessoryControlTapped control: UIControl!) {
            performSegueWithIdentifier("View Crimes", sender: view)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "View Crimes" {
            if let clickView = (sender as? MKAnnotationView)?.annotation as? RadiusAnnotation {
                if let vc = segue.destinationViewController as? ViewCrimesController {
                    vc.crimes = clickView.locArray
                }
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
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    @IBAction func openDrawer(sender: UIBarButtonItem) {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }

}
