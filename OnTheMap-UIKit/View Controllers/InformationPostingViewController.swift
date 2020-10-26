//
//  InformationPostingViewController.swift
//  OnTheMap-UIKit
//
//  Created by Mohammed Tangestani on 10/18/20.
//

import UIKit
import CoreLocation

class InformationPostingViewController: UIViewController {
    
    @IBOutlet weak private var locationTextField: UITextField!
    @IBOutlet weak private var linkTextField: UITextField!
    @IBOutlet weak private var findLocationButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!

    lazy private var geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    
    var isProcessing = false {
        didSet {
            locationTextField.isEnabled = !isProcessing
            linkTextField.isEnabled = !isProcessing
            findLocationButton.isEnabled = !isProcessing
            if isProcessing {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    var mapString: String {
        locationTextField.text ?? ""
    }
    var mediaURL: String {
        linkTextField.text ?? ""
    }
    var latitude: Double {
        placemark?.location?.coordinate.latitude ?? 0.0
    }
    var longitude: Double {
        placemark?.location?.coordinate.longitude ?? 0.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationTextField.delegate = self
        linkTextField.delegate = self
        
        // Do any additional setup after loading the view.
        findLocationButton.addTarget(self, action: #selector(findLocationButtonPressed), for: .touchUpInside)
        
        locationTextField.becomeFirstResponder()
    }
    
    @IBSegueAction
    private func verifyLocation(_ coder: NSCoder) -> VerifyLocationViewController? {
        VerifyLocationViewController(coder: coder, placemark: placemark!)
    }
    
    @objc
    private func findLocationButtonPressed() {
        guard let linkText = linkTextField.text, !linkText.isEmpty else {
            presentAlert(title: "Missing Info", message: "Please provide a valid URL link.")
            return
        }
        isProcessing = true
        forwardGeocode()
    }
    
    private func forwardGeocode() {
        geocoder.geocodeAddressString(locationTextField.text ?? "") { [weak self] (placemarks, error) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isProcessing = false
                self.processGeocodeResponse(with: placemarks, error: error)
            }
        }
    }
    
    private func processGeocodeResponse(with placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            print("Unable to forward geocode this location: \(error.localizedDescription)")
            presentAlert(title: "Location Error", message: "We were not able to find the location you specified.")
            return
        }
        
        if let placemark = placemarks?.first {
            // the new controller will be passed the instance variable placemark
            self.placemark = placemark
            self.performSegue(withIdentifier: "VerifyLocation", sender: nil)
        }
    }
    
    @IBAction
    private func postInformation(_ unwindSegue: UIStoryboardSegue) {
        print("posting information")
        
        isProcessing = true
        OTMClient.postStudentLocation(
            mapString: mapString, mediaURL: mediaURL,
            latitude: latitude, longitude: longitude,
            completion: processPostStudentLocationResponse(_:)
        )
    }
    
    private func processPostStudentLocationResponse(_ result: (Result<PostLocationResponse, Error>)) {
        switch result {
        case .success(let response):
            print("Successfully posted location: \(response)")
            performSegue(withIdentifier: "backToMainVC", sender: nil)
        case .failure(let error):
            // error posting location information
            print("ERROR: \(#function): \(error.localizedDescription)")
            presentAlert(title: "Network Error", message: "Unable to post your location information. Please try again later.")
        }
        isProcessing = false
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

extension InformationPostingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == locationTextField {
            linkTextField.becomeFirstResponder()
        } else {
            linkTextField.resignFirstResponder()
            findLocationButtonPressed()
        }
        return true
    }
}
