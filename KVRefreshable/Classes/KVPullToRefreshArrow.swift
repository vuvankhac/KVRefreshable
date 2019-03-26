/**
 
 Copyright (c) 2017 Vu Van Khac <khacvv0451@gmail.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

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
