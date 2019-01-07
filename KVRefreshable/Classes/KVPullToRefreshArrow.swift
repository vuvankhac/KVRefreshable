//
//  KVPullToRefreshArrow.swift
//  PullToRefresh
//
//  Created by Vu Van Khac on 2/6/17.
//  Copyright © 2017 Janle. All rights reserved.
//

import UIKit
import CoreGraphics

class KVPullToRefreshArrow: UIView {

    var arrowColor: UIColor = .gray
    
    override func draw(_ rect: CGRect) {
        if let c: CGContext = UIGraphicsGetCurrentContext() {
            c.addRect(CGRect(x: 5, y: 0, width: 12, height: 4))
            c.addRect(CGRect(x: 5, y: 6, width: 12, height: 4))
            c.addRect(CGRect(x: 5, y: 12, width: 12, height: 4))
            c.addRect(CGRect(x: 5, y: 18, width: 12, height: 4))
            c.addRect(CGRect(x: 5, y: 24, width: 12, height: 4))
            c.addRect(CGRect(x: 5, y: 30, width: 12, height: 4))
            
            c.move(to: CGPoint(x: 0, y: 34))
            c.addLine(to: CGPoint(x: 11, y: 48))
            c.addLine(to: CGPoint(x: 22, y: 34))
            c.addLine(to: CGPoint(x: 0, y: 34))
            c.closePath()
            
            c.saveGState()
            c.clip()
            
            let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
            let alphaGradientLocations: [CGFloat] = [0, 0.8]
            var alphaGradient: CGGradient?
            
            var components: [CGFloat] = arrowColor.cgColor.components!
            let numComponents: size_t = arrowColor.cgColor.numberOfComponents
            var colors = [CGFloat](repeating: 0.0, count: 8)
            
            switch numComponents {
            case 2:
                colors[4] = components[0]
                colors[0] = colors[4]
                colors[5] = components[0]
                colors[1] = colors[5]
                colors[6] = components[0]
                colors[2] = colors[6]
                
            case 4:
                colors[4] = components[0]
                colors[0] = colors[4]
                colors[5] = components[1]
                colors[1] = colors[5]
                colors[6] = components[2]
                colors[2] = colors[6]
                
            default:
                break
            }
            
            colors[3] = 0
            colors[7] = 1
            
            if arrowColor == .clear {
                var newColors = [CGFloat]()
                for _ in colors {
                    newColors.append(0)
                }
                
                colors = newColors
            }
            
            alphaGradient = CGGradient(colorSpace: colorSpace, colorComponents: colors, locations: alphaGradientLocations, count: 2)
            c.drawLinearGradient(alphaGradient!, start: CGPoint.zero, end: CGPoint(x: 0, y: rect.size.height), options: CGGradientDrawingOptions(rawValue: 0))
            c.restoreGState()
        }
    }
}
