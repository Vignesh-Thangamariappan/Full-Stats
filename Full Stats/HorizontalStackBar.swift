
import UIKit
import Foundation

class HorizontalStackBar : UIView {
    
    /// An array of optional UIColors (clearColor is used when nil is provided) defining the color of each segment.
    var colors = [UIColor?]() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// An array of CGFloat values to define how much of the view each segment occupies.
    // Caution : **Should add up to 1.0.**
    var values = [CGFloat]() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var labels = [String]() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func clearView() {
        self.removeFromSuperview()
    }
    
    override func draw(_ rect: CGRect) {
        
        
        let r = self.bounds // the view's bounds
        let numberOfSegments = values.count // number of segments to render
        
        let ctx = UIGraphicsGetCurrentContext() // get the current context
        
        var cumulativeValue:CGFloat = 0 // store a cumulative value in order to start each line after the last one
        for i in 0..<numberOfSegments {
            
            ctx!.setFillColor(colors[i]?.cgColor ?? UIColor.clear.cgColor) // set fill color to the given color if it's provided, else use clearColor
            let area = CGRect(x:cumulativeValue*r.size.width,y: 0,width: values[i]*r.size.width, height: r.size.height)
            ctx!.fill(area) // fill that given segment
            let label = UILabel(frame: area)
            label.textAlignment = NSTextAlignment.center
            label.adjustsFontSizeToFitWidth = true
            label.textColor = .white
            label.font = UIFont(name: "Helvetica Neue", size: 8)
            if let metricData = UserDefaults.standard.persistentDomain(forName: "metricData") {
                let chat = metricData[MetricsParameters.chats] ?? 0
                let file = metricData[MetricsParameters.fileTransfers] ?? 0
                let link = metricData[MetricsParameters.links] ?? 0
                let web = metricData[MetricsParameters.onWeb] ?? 0
                
                label.text = "\(labels[i] == "Chat" ? chat : (labels[i] == "File" ? file : (labels[i] == "Link" ? link : (labels[i] == "Web" ? web : 0))))"
                self.addSubview(label)
            }
            
            cumulativeValue += values[i] // increment cumulative value
        }
        
    }
}


