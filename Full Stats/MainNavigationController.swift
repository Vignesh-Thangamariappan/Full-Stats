//
//  MainNavigationController.swift
//  Full Stats
//
//  Created by user on 1/2/18.
//  Copyright © 2018 Vignesh. All rights reserved.
//

import UIKit
import GoogleSignIn
import FullAuthIOSClient
import Alamofire
import SwiftyJSON
import SVProgressHUD

class MainNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let accessToken = UserDefaults.standard.value(forKey: "accessToken") {
            requestTokenInfo()
            SVProgressHUD.show()
        
        } else {
            let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC")
            setViewControllers([loginViewController], animated: true)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func requestTokenInfo(){
        
        let auth = FullAuthOAuthService(authDomain: AnywhereWorksParameters.authDomain, clientId: AnywhereWorksParameters.clientId, clientSecret: AnywhereWorksParameters.clientSecret)
        guard let access_token = UserDefaults.standard.value(forKey: "accessToken") as? String else {
            return
        }
        do{
            
            try auth.getTokenInfo(access_token, handler: { (error, errorResponse, accessToken) -> Void in
                
                if let access = accessToken {
                    print(access)
                    print(access.scopes)
                    self.getUserDetails()
                }
                else if let errResponse = errorResponse {
                    print(errResponse)
                    self.refreshAccessToken()
                }
                if let err = error {
                    print(err)
                }
                
            })
            
        } catch {
            print("Error = \(error)")
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
            let value = JSON(response.result.value)
            print(value)
            let user = value["data"]["user"]
            if let name = user["firstName"].string, let email = user["login"].string {
                UserDefaults.standard.set(name, forKey: "userName")
                UserDefaults.standard.set(email, forKey: "email")
                SVProgressHUD.dismiss()
            }
            
            print(user)
        }
    }
    
    func refreshAccessToken() {
        
        guard let refreshToken = UserDefaults.standard.value(forKey: "refreshToken") as? String else {
            print("Tokens not present")
            return
        }
         let auth = FullAuthOAuthService(authDomain: AnywhereWorksParameters.authDomain, clientId: AnywhereWorksParameters.clientId, clientSecret: AnywhereWorksParameters.clientSecret)
        do {

            try auth.refreshAccessToken(refreshToken, handler: { (error, errorResponse, accessResponse) in
                if error == nil {
                if let access = accessResponse {
                    let token = access.accessToken
                    UserDefaults.standard.set(token,forKey: "accessToken")
                    print(access)
                        self.getUserDetails()
                } else if let errResponse = errorResponse {
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Login Expired", message: "Please login again")
                    print("errorResponse")
                    let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC")
                    self.navigationController?.setViewControllers([loginViewController], animated: true)
                }
                } else {
                    print(error)
                }
            })
        } catch {
            print(error)
        }
    }
}
