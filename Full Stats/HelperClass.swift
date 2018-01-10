//
//  AnywhereWorksParameters.swift
//  Full Stats
//
//  Created by user on 1/2/18.
//  Copyright © 2018 Vignesh. All rights reserved.
//

import Foundation
import  UIKit

struct AnywhereWorksParameters {
        
        static let authDomain = "fullcreative"
        
        static let clientId = "29354-13f42f809824f2f32fcd516055d457e1"
        
        static let clientSecret = "3FlHJi310jGcEzmRutxK2N76ronj7t8MBOKUX9Nr"
        
}

struct MetricsParameters {
    
    static let totalMessages = "msgs_sent"
    static let userMessages = "msgs_user"
    static let streamMessages = "msgs_stream"
    static let chats = "msgs_type_chat"
    static let links = "msgs_type_link"
    static let fileTransfers = "msgs_type_file-transfer"
    static let onWeb = "msgs_device_web"
}

struct DataForHorizontalBar {
    
    var label: String
    var color: UIColor
    var value: Int
    var percentage: Float
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UIColor {
    struct FlatColor {
        struct Green {
            static let Fern = UIColor(netHex: 0x6ABB72)
            static let MountainMeadow = UIColor(netHex: 0x3ABB9D)
            static let ChateauGreen = UIColor(netHex: 0x4DA664)
            static let PersianGreen = UIColor(netHex: 0x2CA786)
        }
        
        struct Blue {
            static let PictonBlue = UIColor(netHex: 0x5CADCF)
            static let Mariner = UIColor(netHex: 0x3585C5)
            static let CuriousBlue = UIColor(netHex: 0x4590B6)
            static let Denim = UIColor(netHex: 0x2F6CAD)
            static let Chambray = UIColor(netHex: 0x485675)
            static let BlueWhale = UIColor(netHex: 0x29334D)
        }
        
        struct Violet {
            static let Wisteria = UIColor(netHex: 0x9069B5)
            static let BlueGem = UIColor(netHex: 0x533D7F)
        }
        
        struct Yellow {
            static let Energy = UIColor(netHex: 0xF2D46F)
            static let Turbo = UIColor(netHex: 0xF7C23E)
        }
        
        struct Orange {
            static let NeonCarrot = UIColor(netHex: 0xF79E3D)
            static let Sun = UIColor(netHex: 0xEE7841)
        }
        
        struct Red {
            static let TerraCotta = UIColor(netHex: 0xE66B5B)
            static let Valencia = UIColor(netHex: 0xCC4846)
            static let Cinnabar = UIColor(netHex: 0xDC5047)
            static let WellRead = UIColor(netHex: 0xB33234)
        }
        
        struct Gray {
            static let AlmondFrost = UIColor(netHex: 0xA28F85)
            static let WhiteSmoke = UIColor(netHex: 0xEFEFEF)
            static let Iron = UIColor(netHex: 0xD1D5D8)
            static let IronGray = UIColor(netHex: 0x75706B)
        }
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

extension Date {
    var startOfDay: Date {
        let date = Calendar.current.startOfDay(for: self)
        let newDate = Calendar.current.date(byAdding: .hour, value: 5, to: date)
        let currDate = Calendar.current.date(byAdding: .minute, value: 30, to: newDate!)
        return currDate!
    }
}

