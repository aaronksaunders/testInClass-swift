//
//  MapViewController.swift
//  testInClassSwift
//
//  Created by Aaron saunders on 3/16/15.
//  Copyright (c) 2015 Clearly Innovative Inc. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var detailItem: MasterViewController.PhotoInfo? {
        didSet {
            // Update the view.
            //self.configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        // Do any additional setup after loading the view.
        addAnnotation();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Map Drawing Stuff
    func addAnnotation() {
        // Add Annotation
        let annotation = MKPointAnnotation()
        annotation.title = self.detailItem?.location
        
        
        if let coords = self.detailItem?.coordinates {
            annotation.coordinate = coords
            
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            setCenterOfMapToLocation(coords)
        }
    }

    /* the center of the map */
    func setCenterOfMapToLocation(location: CLLocationCoordinate2D){
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
