//
//  GPSViewController.swift
//  Sensors
//
//  Created by Linda Cobb on 9/22/14.
//  Copyright (c) 2014 TimesToCome Mobile. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GLKit


// latitude, longitude
// altitude - meters above sea level
// timestamp
// distance between points
// speed - meters/sec
// direction - measured in degrees 0' at north and then clockwise

class GPSViewController: UIViewController, CLLocationManagerDelegate
{
    var totalTime = 0
    var distanceX = 0.0
    var currentSpreed = 00
    var accuracy = 0
    var startTime = NSDate()

    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var currentHeading: CLHeading!
    var previousLocation: CLLocation!
    
    
    @IBOutlet var totalTimeLabel: UILabel!
    
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var altitudeLabel: UILabel!
    @IBOutlet  var rotationLabel: UILabel!
    
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var distanceXLabel: UILabel!
    @IBOutlet var distanceYLabel: UILabel!
    
    
    @IBOutlet var startLocationLabel:UILabel!
    @IBOutlet var distanceToStartLocationLabel: UILabel!
    @IBOutlet var directionToStartLocationLabel: UILabel!
    var startLocation:CLLocation!
    
    
    @IBOutlet var accuracySelector: UISegmentedControl!
    
    
    
    
    required init( coder aDecoder: NSCoder ){
        super.init(coder: aDecoder)
    }
    
    
    convenience override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        self.init(nibName: nil, bundle: nil)
    }
    
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(animated: Bool) {}
    
    
    @IBAction func setStartLocation () {
        
        startLocation = locationManager.location
        
        startLocationLabel.text = NSString(format: "long %.4lf, lat %.4lf, altitude: %.4lf", startLocation.coordinate.latitude, startLocation.coordinate.longitude, startLocation.altitude) as String

        
    }
    
    
    
    @IBAction func startTracking() {
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    
        accuracyChange()
    
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        startTime = NSDate()
        totalTime = 0
        distanceX = 0
        
    }
    
    
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        rotationLabel.text = ("Heading: \(newHeading.magneticHeading)")
        currentHeading = newHeading
    }
    
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        
        currentLocation = locations[0] as! CLLocation
        
        longitudeLabel.text = ("long: \(currentLocation.coordinate.longitude)")
        latitudeLabel.text = ("lat: \(currentLocation.coordinate.latitude)")
        altitudeLabel.text = ("alt: \(currentLocation.altitude)")
        speedLabel.text = ("speed: \(currentLocation.speed)")
        
        totalTime = Int(startTime.timeIntervalSinceNow) * -1
        totalTimeLabel.text = ("time: \(totalTime)")
        
       
        if let startLoc = startLocation {
            
            let distanceToStartLocation = currentLocation.distanceFromLocation(currentLocation)
        
            
            let fromLat = GLKMathDegreesToRadians(Float(currentLocation.coordinate.latitude))
            let fromLng = GLKMathDegreesToRadians(Float(currentLocation.coordinate.longitude))
            
            let toLat = GLKMathDegreesToRadians(Float(startLocation.coordinate.latitude))
            let toLng = GLKMathDegreesToRadians(Float(startLocation.coordinate.longitude))
            
            
            
            let ftan = tan(Double(toLat/2.0) + M_PI_4)
            let ttan = tan(Double(fromLat/2.0) + M_PI_4)
            let d_phi = log( ttan/ftan )
            
            let d_long = Double(abs(fromLng - toLng ) % 180.0)
            
            
            var headingHome = GLKMathRadiansToDegrees( Float(atan(Double(d_long/d_phi))))
            if headingHome < 0 { headingHome = 360.0 + headingHome }

            
            distanceToStartLocationLabel.text = NSString(format: "distance back: %.1lf meters", distanceToStartLocation) as String
            directionToStartLocationLabel.text = NSString(format: "direction home: %.1lf '", headingHome) as String
        }
        
        
        if previousLocation != nil {
            distanceX += previousLocation.distanceFromLocation(currentLocation)
        }
            previousLocation = currentLocation
            distanceXLabel.text = ("distance: \(distanceX)" )
        
    }
    
    
  
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus ) {
        println("authorization changed")
    }
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("error \(error)")
    }
    
    
    @IBAction func stopTracking() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    
    @IBAction func accuracyChange() {
        accuracy = self.accuracySelector.selectedSegmentIndex
        if ( accuracy == 0 ){
           locationManager.desiredAccuracy = kCLLocationAccuracyKilometer // 1 km
        }else if ( accuracy == 1 ){
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // 100 m
        }else if ( accuracy == 2 ){
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters // 10 m
        }else if ( accuracy == 3 ){
            locationManager.desiredAccuracy = kCLLocationAccuracyBest    // best
        }else if ( accuracy == 4 ){
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation // navigation
        }

    }
    

}