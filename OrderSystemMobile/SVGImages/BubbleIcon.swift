//
//  BubbleIcon.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 04/09/2024.
//

import Foundation
import SwiftUI

struct BubbleIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.202*width, y: -0.341*height))
        path.addCurve(to: CGPoint(x: 0.376*width, y: -0.212*height), control1: CGPoint(x: 0.269*width, y: -0.312*height), control2: CGPoint(x: 0.334*width, y: -0.271*height))
        path.addCurve(to: CGPoint(x: 0.427*width, y: -0.006*height), control1: CGPoint(x: 0.418*width, y: -0.154*height), control2: CGPoint(x: 0.437*width, y: -0.077*height))
        path.addCurve(to: CGPoint(x: 0.342*width, y: 0.2*height), control1: CGPoint(x: 0.417*width, y: 0.065*height), control2: CGPoint(x: 0.379*width, y: 0.131*height))
        path.addCurve(to: CGPoint(x: 0.215*width, y: 0.38*height), control1: CGPoint(x: 0.306*width, y: 0.268*height), control2: CGPoint(x: 0.272*width, y: 0.341*height))
        path.addCurve(to: CGPoint(x: 0.005*width, y: 0.416*height), control1: CGPoint(x: 0.159*width, y: 0.419*height), control2: CGPoint(x: 0.079*width, y: 0.425*height))
        path.addCurve(to: CGPoint(x: -0.199*width, y: 0.346*height), control1: CGPoint(x: -0.069*width, y: 0.407*height), control2: CGPoint(x: -0.138*width, y: 0.382*height))
        path.addCurve(to: CGPoint(x: -0.363*width, y: 0.202*height), control1: CGPoint(x: -0.261*width, y: 0.309*height), control2: CGPoint(x: -0.315*width, y: 0.261*height))
        path.addCurve(to: CGPoint(x: -0.449*width, y: 0.004*height), control1: CGPoint(x: -0.412*width, y: 0.142*height), control2: CGPoint(x: -0.455*width, y: 0.071*height))
        path.addCurve(to: CGPoint(x: -0.337*width, y: -0.185*height), control1: CGPoint(x: -0.442*width, y: -0.063*height), control2: CGPoint(x: -0.386*width, y: -0.127*height))
        path.addCurve(to: CGPoint(x: -0.19*width, y: -0.333*height), control1: CGPoint(x: -0.287*width, y: -0.244*height), control2: CGPoint(x: -0.245*width, y: -0.297*height))
        path.addCurve(to: CGPoint(x: 0, y: -0.389*height), control1: CGPoint(x: -0.135*width, y: -0.37*height), control2: CGPoint(x: -0.067*width, y: -0.389*height))
        path.addCurve(to: CGPoint(x: 0.202*width, y: -0.341*height), control1: CGPoint(x: 0.068*width, y: -0.389*height), control2: CGPoint(x: 0.136*width, y: -0.371*height))
        path.closeSubpath()
        return path
    }
}
