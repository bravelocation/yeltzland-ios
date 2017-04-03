//
//  LocationsViewController.swift
//  yeltzland
//
//  Created by John Pollard on 06/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import MapKit
import Font_Awesome_Swift

class LocationsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var mapToggleButton: UIBarButtonItem!
    
    var mapView = MKMapView()
    var locationManager = CLLocationManager()
    
    let regionRadius: CLLocationDistance = 600000
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup refresh button
        self.mapToggleButton = UIBarButtonItem(
            title: "Toggle",
            style: .plain,
            target: self,
            action: #selector(LocationsViewController.mapToggleButtonTouchUp)
        )
        self.mapToggleButton.FAIcon = FAType.FAMapO
        self.mapToggleButton.tintColor = AppColors.NavBarTintColor
        self.navigationController?.navigationBar.tintColor = AppColors.NavBarTintColor
        self.navigationItem.rightBarButtonItems = [self.mapToggleButton]
        
        self.navigationItem.title = "Where's The Ground?"
        
        // Setup location manager
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

        // Setup map settings
        self.mapView.mapType = .standard
        self.mapView.frame = view.bounds
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.isZoomEnabled = true
        
        // Setup initial view covering points
        self.mapView.setRegion(LocationManager.instance.mapRegion(), animated: true)
                
        // Add locations on map
        for location in LocationManager.instance.Locations {
            let cooordinate = CLLocationCoordinate2DMake(location.latitude!, location.longitude!)
            let annotation = LocationAnnotation(coordinate: cooordinate, team: location.team)
            self.mapView.addAnnotation(annotation)
        }
        
        // Finally add the map to the view
        self.view.addSubview(mapView)
    }
    
    func mapToggleButtonTouchUp() {
        if (self.mapView.mapType == .standard) {
            self.mapView.mapType = .satellite
        } else {
            self.mapView.mapType = .standard
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.mapView.frame = self.view.bounds
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? LocationAnnotation {
            let identifier = "YLZAnnotation"
            var view: MKAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                let ballImage = UIImage(icon: FAType.FASoccerBallO, size: CGSize(width: 20, height: 20), textColor: AppColors.Evostick, backgroundColor: UIColor.clear)
                
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.image = ballImage
                view.centerOffset = CGPoint(x: 0, y: -10.0)
            }
            
            return view
        }
        else {
            return nil
        }
    }
}
