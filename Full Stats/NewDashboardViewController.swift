//
//  NewDashboardViewController.swift
//  Full Stats
//
//  Created by user on 1/9/18.
//  Copyright © 2018 Vignesh. All rights reserved.
//

import UIKit
import Foundation


class NewDashboardViewController: UIViewController, DashboardDelegate {
    
    
    var typeSegment: UISegmentedControl?
    
 
    func callDelegate() {
        print("Delegate Called")
    }
    
    @IBOutlet weak var theTypeSegment: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        let dashboardTableVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tableView") as! StatisticsTableViewController
        dashboardTableVC.delegate = self
        typeSegment = theTypeSegment
       
    }

    @IBAction func segmentChanged(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name("SegmentChanged"), object: theTypeSegment.selectedSegmentIndex)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.navigationItem.title = "Dashboard"
        tabBarController?.navigationController?.isNavigationBarHidden = false
    }
}
