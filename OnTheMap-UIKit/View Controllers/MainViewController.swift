//
//  TabBarController.swift
//  OnTheMap-UIKit
//
//  Created by Mohammed Tangestani on 10/17/20.
//

import UIKit
import CoreLocation
import Combine

protocol StudentLocationsViewer {
    var locations: [StudentLocation] { get set }
    var lastPostedLocation: CLLocationCoordinate2D { get }
}

extension StudentLocationsViewer {
    var lastPostedLocation: CLLocationCoordinate2D {
        locations.first?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    }
}

class MainViewController: UITabBarController {
    
    private let viewModel: MainViewModel = MainViewModel()
    
    private var locations: [StudentLocation] {
        viewModel.locations
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshData()
    }
    
    @IBAction private func backToMainVC(_ unwindSegue: UIStoryboardSegue) {
        if let _ = unwindSegue.source as? InformationPostingViewController {
            refreshData()
        }
    }
    
    @IBAction private func refreshData() {
        viewModel.fetch { [unowned self] error in
            if let error = error {
                self.presentAlert(title: "Network Error", message: error.localizedDescription)
                return
            }
            
            for child in self.children {
                if var vc = child as? StudentLocationsViewer {
                    vc.locations = locations
                }
            }
        }
    }
    
    @IBAction private func logout(_ sender: Any) {
        viewModel.logout {
            self.performSegue(withIdentifier: "logout", sender: nil)
        }
    }
}
