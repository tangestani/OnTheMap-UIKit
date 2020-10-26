//
//  MapViewController.swift
//  OnTheMap-UIKit
//
//  Created by Mohammed Tangestani on 10/17/20.
//

import UIKit
import MapKit

class MapViewController: UIViewController, StudentLocationsViewer {
    var locations = [StudentLocation]() {
        didSet {
            annotations = locations.map { location in
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.coordinate
                annotation.title = location.name
                annotation.subtitle = location.mediaURL
                return annotation
            }
            
            let span = MKCoordinateSpan(latitudeDelta: 45, longitudeDelta: 180)
            let region = MKCoordinateRegion(center: lastPostedLocation, span: span)
            DispatchQueue.main.async { [weak self] in
                self?.mapView.setRegion(region, animated: true)
            }
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var annotations = [MKPointAnnotation]() {
        didSet {
            guard let mapView = mapView else { return }
            mapView.removeAnnotations(oldValue)
            mapView.addAnnotations(annotations)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
        let span = MKCoordinateSpan(latitudeDelta: 45, longitudeDelta: 180)
        let region = MKCoordinateRegion(center: lastPostedLocation, span: span)
        mapView.setRegion(region, animated: false)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        pinView!.annotation = annotation
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let urlString: String = view.annotation?.subtitle?.flatMap { $0 } ?? ""
            guard var components = URLComponents(string: urlString) else { return }
            if components.scheme != "http" && components.scheme != "https" {
                // Use https if the url is missing a valid HTTP scheme
                components.scheme = "https"
            }
            guard let url = components.url else { return }
            guard UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
