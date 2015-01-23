//
//  ViewController.swift
//  WhereAmI
//
//  Created by Marshall Upshur on 1/20/15.
//  Copyright (c) 2015 Marshall Upshur. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var manager:CLLocationManager!
    var activePlace = Dictionary<String,String>()
    var placeAction = ""
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    @IBAction func findMe(sender: AnyObject) {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        if placeAction == "add" {
            placeAction = ""
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
        } else {
            var latitude:CLLocationDegrees = NSString(string: activePlace["lat"]!).doubleValue
            var longitude:CLLocationDegrees = NSString(string: activePlace["lon"]!).doubleValue
            var latDelta:CLLocationDegrees = 0.01
            var lonDelta:CLLocationDegrees = 0.01
            var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            var region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            
            mapView.setRegion(region, animated: true)
            
            var annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = activePlace["name"]!
            
            mapView.addAnnotation(annotation)
        }
        
        var uilpgr = UILongPressGestureRecognizer(target: self, action: "action:")
        uilpgr.minimumPressDuration = 2.0
        
        mapView.addGestureRecognizer(uilpgr)
        
    }
    
    func action(gestureRecognizer:UIGestureRecognizer) {
//        println("long press")
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            var touchPoint = gestureRecognizer.locationInView(self.mapView)
            
            var newCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            
            var loc = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocation(loc, completionHandler:{(placemarks, error) in
                
                if error != nil { println(error) }
                else {
                    //                println(placemarks)
                    let p = CLPlacemark(placemark: placemarks?[0] as CLPlacemark)
                    
                    var subThoroughfare:String = ""
                    var thoroughfare:String = ""
                    if p.subThoroughfare != nil {
                        subThoroughfare = p.subThoroughfare
                    }
                    if p.thoroughfare != nil {
                        thoroughfare = p.thoroughfare
                    }
                    
                    var title = "\(subThoroughfare) \(thoroughfare)"
                    if title == " " {
                        var date = NSDate()
                        title = "Added \(date)"
                    }
                    
                    places.append(["name": title, "lat": String(format: "%f", newCoordinate.latitude), "lon": String(format: "%f",  newCoordinate.longitude)])
                    
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = newCoordinate
                    annotation.title = title
                    
                    self.mapView.addAnnotation(annotation)
                }
            })
            
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
//    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
//        if (segue.identifier == "back") {
//            self.navigationController?.navigationBarHidden = false
//        }
//    }
//    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var userLocation:CLLocation = locations[0] as CLLocation
        
//        println(userLocation)
        
//        latitudeLabel.text = "\(userLocation.coordinate.latitude)"
//        latitudeLabel.text = String(format: "%f", userLocation.coordinate.latitude)
//        longitudeLabel.text = String(format: "%f", userLocation.coordinate.longitude)
        
        
        var latitude:CLLocationDegrees = userLocation.coordinate.latitude
        var longitude:CLLocationDegrees = userLocation.coordinate.longitude
        var latDelta:CLLocationDegrees = 0.01
        var lonDelta:CLLocationDegrees = 0.01
        var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        var region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        mapView.setRegion(region, animated: true)

        manager.stopUpdatingLocation()

        
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler:{(placemarks, error) in
            
            if error != nil { println(error) }
            else {
//                println(placemarks)
                let p = CLPlacemark(placemark: placemarks?[0] as CLPlacemark)
                
                self.addressLabel.text = "\(p.subThoroughfare) \(p.thoroughfare) \n"
                
                
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

