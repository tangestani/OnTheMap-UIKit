//
//  VerifyLocationViewController.swift
//  OnTheMap-UIKit
//
//  Created by Mohammed Tangestani on 10/19/20.
//

import UIKit
import MapKit

class VerifyLocationViewController: UIViewController {

    @IBOutlet weak private var mapView: MKMapView!
    
    let placemark: CLPlacemark
    
    var coordinate: CLLocationCoordinate2D {
        placemark.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    }
    
    required init?(coder: NSCoder, placemark: CLPlacemark) {
        self.placemark = placemark
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.layoutMargins = .init(top: 0, left: 0, bottom: 44, right: 0)
        mapView.addAnnotation(MKPlacemark(placemark: placemark))
        
        let span = MKCoordinateSpan(latitudeDelta: 45, longitudeDelta: 180)
        let region = MKCoordinateRegion(center: .init(), span: span)
        mapView.setRegion(region, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.setCenter(coordinate, animated: true)
        let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
