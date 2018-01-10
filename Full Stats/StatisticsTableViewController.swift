//
//  StatisticsTableViewController.swift
//  Full Stats
//
//  Created by user on 1/9/18.
//  Copyright © 2018 Vignesh. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON
import PieCharts
import SVProgressHUD
import SwiftCharts

protocol DashboardDelegate {
    var typeSegment:UISegmentedControl? {
        get
    }
    func callDelegate()
}

class StatisticsTableViewController: UITableViewController {
    
    
    @IBOutlet weak var messageTypeCollectionView: UICollectionView!
    @IBOutlet weak var container: UIView!
    //    @IBOutlet weak var container: UIView!
    @IBOutlet weak var deviceTypeChart: HorizontalStackBar!
    var typeSegment = UISegmentedControl(items: ["One","Two"])
    @IBOutlet weak var messageTypeChart: UIView!
    @IBOutlet weak var pieChart: PieChart!
    @IBOutlet weak var lastWeekPieChart: PieChart!
    var chart: Chart?
    var sum = 0.0
    var horizontalBar = HorizontalStackBar()
    var deviceHorizontalBar = HorizontalStackBar()
    static let alpha: CGFloat = 0.4
    let colors = [
        UIColor.FlatColor.Blue.PictonBlue,
        UIColor.FlatColor.Violet.Wisteria,
        UIColor.FlatColor.Blue.Chambray,
        UIColor.FlatColor.Blue.Mariner,
        UIColor.FlatColor.Orange.NeonCarrot,
        UIColor.FlatColor.Blue.CuriousBlue,
        UIColor.FlatColor.Green.Fern,
        ]
    
    var horizontalBarData = [
        DataForHorizontalBar(label: "NO values Found", color: UIColor.blue, value: 0, percentage: 0)
    ]
    var deviceTypeHorizontalBarData = [DataForHorizontalBar]()
    
    var delegate: DashboardDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.setDefaultMaskType(.clear)
        pieChart.delegate = self
        pieChart.selectedOffset = 0
        lastWeekPieChart.delegate = self
        typeSegment.selectedSegmentIndex = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(segmentChanged), name: NSNotification.Name("SegmentChanged"), object: nil)
        lastWeekPieChart.selectedOffset = 0
        getMetricsData()
        let deviceCollectionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "deviceCollectionView")
        self.addChildViewController(deviceCollectionVC)
        deviceCollectionVC.view.frame = container.frame
        self.tableView.addSubview(deviceCollectionVC.view)
        //                self.container.addSubview(deviceCollectionVC.view)
        deviceCollectionVC.didMove(toParentViewController: self)
        // Do any additional setup after loading the view.
    }
    
    func getMetricsData() {
        
        
        guard let accessToken = UserDefaults.standard.value(forKey: "accessToken") as? String, let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("NO VALUE FOUND")
            return
        }
        SVProgressHUD.show(withStatus: "Loading Data")
        let date = Date().startOfDay
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: date)!
        var startTime:Int = Int(yesterday.timeIntervalSince1970) * 1000
        let endTime:Int = Int(yesterday.timeIntervalSince1970) * 1000
        if typeSegment.selectedSegmentIndex == 1 {
            startTime = Int(lastWeek.timeIntervalSince1970) * 1000
        }
        print(startTime)
        guard let url = URL(string: "https://api.anywhereworks.com/api/v1/admin/metrics/email/\(email)?startTime=\(startTime)&endTime=\(endTime)") else {
            print("URL NOT VALID")
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        Alamofire.request(request).responseJSON { response in
            print(response)
            
            let value = JSON(response.result.value)
            let metricData = value["data"]["metrics"]
            //                let yesterdayMetric = value[0][0]
            print(metricData)
            guard let data = metricData.dictionaryObject else {
                SVProgressHUD.dismiss()
                self.showAlert(title: "No data found for yesterday", message: "") { (alert) in
                    
                    self.typeSegment.selectedSegmentIndex = self.typeSegment.selectedSegmentIndex == 0 ? 1 : 0
                    self.getMetricsData()
                }
                return
            }
            UserDefaults.standard.setPersistentDomain(data, forName: "metricData")
            print(metricData["msgs_sent"])
            guard let totalMessages = metricData["msgs_sent"].double, let yesterdayUserMessages = metricData["msgs_user"].int else {
                SVProgressHUD.dismiss()
                self.showAlert(title: "Unable to load data", message: "Please try again")
                return
            }
            let yesterdayStreamMessages = metricData["msgs_stream"].int ?? 0
            let link = metricData["msgs_type_link"].double ?? 0
            let chat = metricData["msgs_type_chat"].double ?? 0
            let file = metricData["msgs_type_file-transfer"].double ?? 0
            SVProgressHUD.dismiss()
         
            self.sum = totalMessages
            
            let ratioFile = file/Double(totalMessages)>0.1 ? file/totalMessages: (file/totalMessages == 0 ? 0 : 0.1)
            let ratioLink = link/Double(totalMessages)>0.1 ? link/totalMessages : (link/totalMessages == 0 ? 0 : 0.1)
            let ratioChat = ratioFile + ratioLink > (1 - chat/totalMessages) ? 0.8 : chat/totalMessages
            self.horizontalBar.clearView()
            
            
            self.horizontalBar = HorizontalStackBar(frame: self.messageTypeChart.frame)
            
            self.horizontalBarData = [
                DataForHorizontalBar(label: "Chat", color: self.colors[0], value: Int(chat), percentage: Float(Double(chat/totalMessages).rounded(toPlaces: 3)*100)),
                DataForHorizontalBar(label: "File", color: self.colors[1], value: Int(file), percentage: Float(Double(file/totalMessages).rounded(toPlaces: 3)*100)),
                DataForHorizontalBar(label: "Link", color: self.colors[2], value: Int(link), percentage: Float(Double(link/totalMessages).rounded(toPlaces: 3)*100))
            ]
            
            self.messageTypeCollectionView.delegate = self
            self.messageTypeCollectionView.dataSource = self
            self.messageTypeCollectionView.reloadInputViews()
            
            self.horizontalBar.colors = self.colors
            self.horizontalBar.values = [CGFloat(ratioChat),CGFloat(ratioFile),CGFloat(ratioLink)]
            self.horizontalBar.labels = ["Chat","File","Link"]
            
            self.messageTypeChart.addSubview(self.horizontalBar)
            
            
            let deviceWeb = metricData["msgs_device_web"].double ?? 0
            self.deviceHorizontalBar.clearView()
            let ratioWeb = deviceWeb/totalMessages
            self.deviceHorizontalBar = HorizontalStackBar(frame: self.deviceTypeChart.frame)
            self.deviceHorizontalBar.colors = [UIColor.FlatColor.Yellow.Energy,UIColor.FlatColor.Green.PersianGreen, UIColor.FlatColor.Gray.IronGray]
            self.deviceHorizontalBar.values = [CGFloat(ratioWeb)]
            self.deviceHorizontalBar.labels = ["Web"]
            self.deviceTypeChart.addSubview(self.deviceHorizontalBar)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DeviceDataDone"), object: nil)
            
            if self.typeSegment.selectedSegmentIndex == 0 {
                self.pieChart.isHidden = false
                self.lastWeekPieChart.isHidden = true
                self.pieChart.outerRadius = self.pieChart.frame.height/2 - 25
                self.pieChart.layers = [self.createPlainTextLayer(), self.createTextWithLinesLayer()]
                
                var pieChartModels = [PieSliceModel]()
                if yesterdayStreamMessages == 0 {
                    pieChartModels = [PieSliceModel(value: Double(yesterdayUserMessages), color: self.colors[3])]
                } else if yesterdayUserMessages == 0 {
                    pieChartModels = [PieSliceModel(value: Double(yesterdayStreamMessages), color: self.colors[6]) ]
                } else {
                    pieChartModels = [
                        PieSliceModel(value: Double(yesterdayUserMessages), color: self.colors[3]),
                        PieSliceModel(value: Double(yesterdayStreamMessages), color: self.colors[6])
                    ]
                }
                self.pieChart.models = pieChartModels
                
                
            } else {
                self.pieChart.isHidden = true
                self.lastWeekPieChart.isHidden = false
                self.lastWeekPieChart.outerRadius = self.lastWeekPieChart.frame.height/2 - 25
                self.lastWeekPieChart.layers = [self.createPlainTextLayer(), self.createTextWithLinesLayer()]
                var pieChartModels = [PieSliceModel]()
                if yesterdayStreamMessages == 0 {
                    pieChartModels = [PieSliceModel(value: Double(yesterdayUserMessages), color: self.colors[3])]
                } else if yesterdayUserMessages == 0 {
                    pieChartModels = [PieSliceModel(value: Double(yesterdayStreamMessages), color: self.colors[6]) ]
                } else {
                    pieChartModels = [
                        PieSliceModel(value: Double(yesterdayUserMessages), color: self.colors[3]),
                        PieSliceModel(value: Double(yesterdayStreamMessages), color: self.colors[6])
                    ]
                }
                self.lastWeekPieChart.models = pieChartModels
                
            }
            
            self.messageTypeCollectionView.reloadData()
            
            if let error = response.error{
                print(error)
                SVProgressHUD.dismiss()
                self.showAlert(title: "Oops! Something went Wron", message: "Unable to fetch data")
            }
            
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        pieChart.delegate = self
    }
    
    @objc func segmentChanged() {
        typeSegment.selectedSegmentIndex = (typeSegment.selectedSegmentIndex == 0) ? 1 : 0
        getMetricsData()
    }
    func createPlainTextLayer() -> PiePlainTextLayer {
        
        let textLayerSettings = PiePlainTextLayerSettings()
        textLayerSettings.viewRadius = 60
        textLayerSettings.hideOnOverflow = false
        textLayerSettings.label.font = UIFont.systemFont(ofSize: 8)
        textLayerSettings.label.textGenerator = {slice in
            return String(describing: Int(slice.data.model.value))
        }
        
        let textLayer = PiePlainTextLayer()
        textLayer.settings = textLayerSettings
        return textLayer
    }
    
    func createTextWithLinesLayer() -> PieLineTextLayer {
        let lineTextLayer = PieLineTextLayer()
        var lineTextLayerSettings = PieLineTextLayerSettings()
        lineTextLayerSettings.lineColor = UIColor.lightGray
        lineTextLayerSettings.label.font = UIFont.systemFont(ofSize: 14)
        lineTextLayerSettings.label.textGenerator = {slice in
            return slice.data.id == 0 ? "User" : "Stream"
        }
        
        lineTextLayer.settings = lineTextLayerSettings
        return lineTextLayer
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
}

extension StatisticsTableViewController: PieChartDelegate {
    
    func onSelected(slice: PieSlice, selected: Bool) {
        print("Selected: \(selected), slice: \(slice)")
    }
    
    
}

extension StatisticsTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return horizontalBarData.count
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.navigationController?.isNavigationBarHidden = false
        tabBarController?.navigationItem.title = "Dashboard"
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chartLegend", for: indexPath)
        let imageView = cell.viewWithTag(3) as! UIImageView
        let descriptionLabel = cell.viewWithTag(1) as! UILabel
        let percentageLabel = cell.viewWithTag(2) as! UILabel
        imageView.layer.cornerRadius = ((imageView.frame.size.height) / 2)
        imageView.clipsToBounds = true
        imageView.backgroundColor = horizontalBarData[indexPath.row].color
        
        descriptionLabel.text = horizontalBarData[indexPath.row].label
        percentageLabel.text = "\(horizontalBarData[indexPath.row].percentage)%"
        return cell
        
    }
    
}


