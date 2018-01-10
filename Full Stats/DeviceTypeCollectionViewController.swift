//
//  DeviceTypeCollectionViewController.swift
//  Full Stats
//
//  Created by user on 1/9/18.
//  Copyright © 2018 Vignesh. All rights reserved.
//

import UIKit

private let reuseIdentifier = "deviceChartLegend"

class DeviceTypeCollectionViewController: UICollectionViewController {

    
    var collectionViewData = [DataForHorizontalBar]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "DeviceDataDone"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getData()
        
    }
    @objc func getData() {
        guard let metricData = UserDefaults.standard.persistentDomain(forName: "metricData"), let totalMessages = metricData["msgs_sent"] as? Double else {
            print("Failed")
            return
        }
        
        let deviceWeb = metricData["msgs_device_web"] as? Double ?? 0
        
        let ratioWeb = deviceWeb/totalMessages
        
        
        
        collectionViewData = [DataForHorizontalBar(label: "Web", color: UIColor.FlatColor.Yellow.Energy, value: Int(deviceWeb), percentage: Float(Double(ratioWeb.rounded(toPlaces: 3)*100)))
        ]
        self.collectionView?.reloadData()

    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return collectionViewData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        let imageView = cell.viewWithTag(3) as! UIImageView
        let descriptionLabel = cell.viewWithTag(1) as! UILabel
        let percentageLabel = cell.viewWithTag(2) as! UILabel
        imageView.layer.cornerRadius = ((imageView.frame.size.height) / 2)
        imageView.clipsToBounds = true
        imageView.backgroundColor = collectionViewData[indexPath.row].color

        descriptionLabel.text = collectionViewData[indexPath.row].label
        percentageLabel.text = "\(collectionViewData[indexPath.row].percentage)%"
        return cell
    }

}
