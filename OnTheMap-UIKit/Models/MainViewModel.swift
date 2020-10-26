//
//  AppModel.swift
//  OnTheMap-UIKit
//
//  Created by Mohammed Tangestani on 10/26/20.
//

import Foundation
import CoreLocation

class MainViewModel: ObservableObject {
    private(set) var locations: [StudentLocation] = .init()
    
    func fetch(completion: @escaping (Error?) -> Void) {
        print("fetching data")
        OTMClient.getStudentLocations { (result) in
            switch result {
            case .success(let locations):
                self.locations = locations
                completion(nil)
            case .failure(let error):
                print("Error fetching data: \(error.localizedDescription)")
                completion(error)
            }
        }
    }
    
    func logout(completion: @escaping () -> Void) {
        OTMClient.logout { (error) in
            if let error = error {
                print("Error logging out: \(error.localizedDescription)")
            }
            print("logged out")
            completion()
        }
    }
}
