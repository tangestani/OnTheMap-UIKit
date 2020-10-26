//
//  AppModel.swift
//  OnTheMap-UIKit
//
//  Created by Mohammed Tangestani on 10/26/20.
//

import Foundation
import CoreLocation

class MainViewModel {
    private(set) var locations: [StudentLocation] = .init()
    var lastPostedLocation: CLLocationCoordinate2D {
        locations.first?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    }
}
