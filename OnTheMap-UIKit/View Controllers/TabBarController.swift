//
//  TabBarController.swift
//  OnTheMap-UIKit
//
//  Created by Mohammed Tangestani on 10/17/20.
//

import UIKit

protocol StudentLocationsViewer {
    var locations: [StudentLocation] { get set }
}

class MainViewController: UITabBarController {
    
    private var locations = [StudentLocation]() {
        didSet {
            print("updating children")
            for child in self.children {
                if var vc = child as? StudentLocationsViewer {
                    vc.locations = locations
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshData()
    }
    
    @IBAction
    private func backToMainVC(_ unwindSegue: UIStoryboardSegue) {
        if let _ = unwindSegue.source as? InformationPostingViewController {
            refreshData()
        }
    }
    
    @IBAction func refreshData() {
        print("fetching data")
        OTMClient.getStudentLocations { (result) in
            switch result {
            case .success(let locations):
                self.locations = locations
            case .failure(let error):
                print(error)
                self.showAlertForError(error)
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        OTMClient.logout { (error) in
            if let error = error {
                print("Error logging out: \(error.localizedDescription)")
            }
            print("logged out")
            self.performSegue(withIdentifier: "logout", sender: nil)
        }
    }
    
    private func showAlertForError(_ error: Error) {
        let alert = UIAlertController(title: "Network Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
