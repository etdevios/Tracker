//
//  UIColor+Extension.swift
//  Tracker
//
//  Created by Eduard Tokarev on 03.05.2023.
//

import UIKit

extension UIColor {
    static var trBackground: UIColor { UIColor(named: "TR-Background") ?? .clear }
    static var trBlack: UIColor { UIColor(named: "TR-Black") ?? .clear }
    static var trBlue: UIColor { UIColor(named: "TR-Blue") ?? .clear }
    static var trGray: UIColor { UIColor(named: "TR-Gray") ?? .clear }
    static var trLightGray: UIColor { UIColor(named: "TR-LightGray") ?? .clear }
    static var trRed: UIColor { UIColor(named: "TR-Red") ?? .clear }
    static var trWhite: UIColor { UIColor(named: "TR-White") ?? .clear }
    
    static let toggleBlackWhiteColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.black
        } else {
            return UIColor.white
        }
    }
    
    static func hexString(from color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        return String.init(
            format: "%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
    }

    static func color(from hex: String) -> UIColor {
        var rgbValue:UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
