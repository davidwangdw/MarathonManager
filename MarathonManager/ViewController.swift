//
//  ViewController.swift
//  MarathonManager
//
//  Created by David Wang on 4/5/17.
//  Copyright © 2017 David Wang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import HealthKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var isPaused: Bool = false
    
    var seconds = 0.0
    var distance = 0.0
    
    lazy var locations = [CLLocation]()
    lazy var timer = Timer()
    
    //for location
    let manager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Access the last object from locations to get perfect current location
        /*if let location = locations.last {
            let span = MKCoordinateSpanMake(0.00775, 0.00775)
            let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude)
            let region = MKCoordinateRegionMake(myLocation, span)
            mapView.setRegion(region, animated: true)
        }
        self.mapView.showsUserLocation = true
        manager.stopUpdatingLocation()*/
        
        if let location = locations.last {
            let span = MKCoordinateSpanMake(0.00775, 0.00775)
            let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude)
            let region = MKCoordinateRegionMake(myLocation, span)
            mapView.setRegion(region, animated: true)
        }
        self.mapView.showsUserLocation = true
        //manager.stopUpdatingLocation()
        
        for location in locations {
            
            let howRecent = location.timestamp.timeIntervalSinceNow
            
            if abs(howRecent) < 10 && location.horizontalAccuracy < 20 {
                //update distance
                if self.locations.count > 0 {
                    distance += location.distance(from: self.locations.last!)
                    
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    //instantPace = location.distance(from: self.locations.last!)/(location.timestamp.timeIntervalSince(self.locations.last!.timestamp))
                    
                    //let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
                    //mapView2.setRegion(region, animated: true)
                    
                    //mapView2.add(MKPolyline(coordinates: &coords, count: coords.count))
                    
                    /*if previousAlt == -1000{
                        previousAlt = location.altitude
                    }
                    if previousAlt < location.altitude{
                        vertClimb += location.altitude-previousAlt
                    }
                    if previousAlt > location.altitude{
                        vertDescent += previousAlt-location.altitude
                    }
                    previousAlt=location.altitude*/
                }
                
                //save location
                self.locations.append(location)
            }
        }

    }
    
    func eachSecond(_ timer: Timer) {
        seconds += 1
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(seconds))
        let secondsQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: Double(s))
        let minutesQuantity = HKQuantity(unit: HKUnit.minute(), doubleValue: Double(m))
        let hoursQuantity = HKQuantity(unit: HKUnit.hour(), doubleValue: Double(h))
        print("Time: "+hoursQuantity.description+" "+minutesQuantity.description+" "+secondsQuantity.description)
        //timeLabel.text = "Time: "+hoursQuantity.description+" "+minutesQuantity.description+" "+secondsQuantity.description
        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)
        //distanceLabel.text = "Distance: " + distanceQuantity.description
        print("Distance: " + distanceQuantity.description)
        
        var fiveKReached: Bool = false
        
        if distance > 50.0 {
            fiveKReached = true
            
            print("you went 50 meters!")
        }
        
        //paceLabel.text = "Current speed: "+String((instantPace*3.6*10).rounded()/10)+" km/h"//"Pace: "+String((distance/seconds*3.6*10).rounded()/10)+" km/h"
        
        //climbLabel.text = "Total climb: "+String((vertClimb*10).rounded()/10)+" m"
        //descentLabel.text = "Total descent: "+String((vertDescent*10).rounded()/10)+" m"
        
        /*checkNextBadge()
        if let upcomingBadge = upcomingBadge {
            let nextBadgeDistanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: upcomingBadge.distance! - distance)
            nextBadgeLabel.text = "\(nextBadgeDistanceQuantity.description) until \(upcomingBadge.name!)"
            nextBadgeImageView.image = UIImage(named: upcomingBadge.imageName!)
        }*/
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    @IBAction func updateCurrentLocation(_ sender: Any) {
        manager.startUpdatingLocation()
        print("updateCurrentLocation button")
    }
    
    @IBAction func startTrackingRun(_ sender: Any) {
        print("startTrackingRun button")
        
        startTrackingRunFunction()
    }
    @IBAction func pauseTrackingRun(_ sender: Any) {
        print("pauseTrackingRun button")
        
        pauseTrackingRunFunction()
    }
    
    @IBAction func stopTrackingRun(_ sender: Any) {
        print("stopTrackingRun button")
        
        stopTrackingRunFunction()
    }
    
    func startTrackingRunFunction() {
        print("in startTrackingRunFunction func")
        
        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepingCapacity: false)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(eachSecond(_:)), userInfo: nil, repeats: true)
        manager.startUpdatingLocation()
    }
    
    func pauseTrackingRunFunction() {
        print("in pauseTrackingRunFunction func")
        
        if isPaused == true {
            print("in isPaused, true")
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(eachSecond(_:)), userInfo: nil, repeats: true)
            manager.startUpdatingLocation()
            isPaused = false
        }
        
        if isPaused == false {
            print("in isPaused, false")
            timer.invalidate()
            manager.stopUpdatingLocation()
            isPaused = true
        }
        
    }
    func stopTrackingRunFunction() {
        print("in stopTrackingRunFunction func")
        
        timer.invalidate()
        manager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        
        centerMapOnLocation(location: initialLocation)*/
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }



}

