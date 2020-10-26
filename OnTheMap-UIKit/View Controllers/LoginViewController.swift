//
//  ViewController.swift
//  OnTheMap-UIKit
//
//  Created by Mohammed Tangestani on 10/16/20.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func login(_ sender: Any) {
        let username = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        OTMClient.login(username: username, password: password) { (error) in
            if let error = error {
                self.presentAlert(title: "Login Error", message: error.localizedDescription)
            } else {
                self.performSegue(withIdentifier: "loginSuccessful", sender: nil)
            }
        }
    }
    
    @IBAction func signup(_ sender: Any) {
        let url = URL(string: "https://auth.udacity.com/sign-up")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func unwindToLoginVC(_ unwindSegue: UIStoryboardSegue) {
    }
}

extension UIViewController {
    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
