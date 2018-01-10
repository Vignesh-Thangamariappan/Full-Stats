//
//  ViewController.swift
//  Full Stats
//
//  Created by user on 12/28/17.
//  Copyright © 2017 Vignesh. All rights reserved.
//

import UIKit
import GoogleSignIn
import Alamofire
import FullAuthIOSClient
import SafariServices
import SVProgressHUD
import SwiftyJSON

class LoginViewController: UIViewController, GIDSignInUIDelegate, SFSafariViewControllerDelegate {
    
    var safari = SFSafariViewController(url: URL(string:"https://www.google.com")!)
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        SVProgressHUD.setDefaultStyle(.dark)
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func fullSignInTapped() {
        //        let myURL = URL(string: "https://access.anywhereworks.com/o/oauth2/auth?response_type=code&client_id=29354-13f42f809824f2f32fcd516055d457e1&scope=awapis.identity&redirect_uri=com.fullcreative.Full-Stats:/oauth2callback&access_type=offline&approval_prompt=force")
        //
        let auth = AuthCodeRequest(authDomain: AnywhereWorksParameters.authDomain, clientId: AnywhereWorksParameters.clientId, scopes: ["awapis.identity"])
        do {            
            let url = try auth.getAuthCodeUrl(withRedirectUrl: "com.fullcreative.Full-Stats:/oauth2callback")
            print(url)
            
            safari = SFSafariViewController(url: url)
            safari.delegate = self
            NotificationCenter.default.addObserver(self, selector: #selector(fullLogin(notification:)), name: Notification.Name("LoginNotification"), object: nil)
            
            self.present(safari, animated: true, completion: nil)
        } catch {
            print(error)
        }
    }
    
    @objc func fullLogin(notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("LoginNotification"), object: nil)
        
        guard let url = notification.object as? NSURL, let query = url.query else{
            print("unable to retrieve")
            return
        }
        
        let authorization = query
        print(authorization)
        self.safari.dismiss(animated: true , completion: nil)
        SVProgressHUD.show(withStatus: "Logging In")
        
        if authorization == "error=access_denied" {
            print("error")
        } else {
            
            let splitCode = authorization.split(separator: "=")
            if let code = splitCode.last {
                print(String(code))
                requestAccessToken(forCode: String(code))
            }
        }
        
    }
    
    
    func requestAccessToken(forCode code: String) {
        
        let auth = FullAuthOAuthService(authDomain: AnywhereWorksParameters.authDomain, clientId: AnywhereWorksParameters.clientId, clientSecret: AnywhereWorksParameters.clientSecret)
        do {
            
            try auth.requestAccessToken(ForAuthCode: code, redirectUrl: "com.fullcreative.Full-Stats:/oauth2callback") { (error, errorResponse, accessResponse) in
                if let access = accessResponse {
                    let accessToken = access.accessToken
                    let refreshToken = access.refreshToken
                    UserDefaults.standard.set(accessToken, forKey: "accessToken")
                    UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                    self.getUserDetails()
                }
                    
                else if let err = error {
                    print(err)
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Unable to Login", message: "Please try again")
                    
                    
                }
            }
        } catch {
            print("failure")
            print(error)
            SVProgressHUD.dismiss()
        }
        
    }
    
    func getUserDetails() {
        
        
        guard let url = URL(string: "https://api.anywhereworks.com/api/v1/user/me"), let accessToken = UserDefaults.standard.value(forKey: "accessToken") as? String else {
            return
        }
        print(accessToken)
        var request = URLRequest(url: url)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        Alamofire.request(request).responseJSON { response in
            if response.error == nil {
                let value = JSON(response.result.value)
                print(value)
                let user = value["data"]["user"]
                if let name = user["firstName"].string, let email = user["login"].string {
                    UserDefaults.standard.set(name, forKey: "userName")
                    UserDefaults.standard.set(email, forKey: "email")
                }
                SVProgressHUD.dismiss()
                let tabBarViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBar")
                self.navigationController?.setViewControllers([tabBarViewController], animated: true)
                print(user)
                
            } else {
                print(response.error)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    
    
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("Safari closed before authorization")
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message:String, completionHandler: @escaping (UIAlertAction)->Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completionHandler))
        self.present(alert, animated: true, completion: nil)
    }
}

