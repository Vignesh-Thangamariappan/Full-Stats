//
//  SettingsTableViewController.swift
//  Full Stats
//
//  Created by user on 12/29/17.
//  Copyright © 2017 Vignesh. All rights reserved.
//

import UIKit
import GoogleSignIn
import FullAuthIOSClient
import SVProgressHUD

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let email = UserDefaults.standard.value(forKey: "email") as? String {
            emailLabel.text = email
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.navigationController?.isNavigationBarHidden = false
        tabBarController?.navigationItem.title = "Settings"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    @IBAction func signOutTapped() {
    let alert = UIAlertController(title: "Are you sure", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (yesAction) in
            SVProgressHUD.show(withStatus: "Signing Out")
        guard let accessToken = UserDefaults.standard.value(forKey: "accessToken") as? String else {
            print("Access Token not available")
            return
        }
        let auth = FullAuthOAuthService(authDomain: AnywhereWorksParameters.authDomain)
        do {
        try auth.revokeAccessToken(accessToken: accessToken, handler: { (success, error, errorResponse) in
            if success {
                UserDefaults.standard.removeObject(forKey: "accessToken")
                UserDefaults.standard.removeObject(forKey: "refreshToken")
                UserDefaults.standard.removeObject(forKey: "userName")
                SVProgressHUD.dismiss()
                let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC")
                self.navigationController?.setViewControllers([loginViewController], animated: true)
            } else if let errResponse = errorResponse {
                print(errResponse)
                SVProgressHUD.dismiss()
                self.showAlert(title: "Something went wrong", message: "Please try again")
                return
            }
            
        })
        } catch {
            print("error = \(error)")
            SVProgressHUD.dismiss()
            self.showAlert(title: "Something went wrong", message: "Please try again")
            return
        }
       }))
        present(alert, animated: true, completion: nil)
    }

}
