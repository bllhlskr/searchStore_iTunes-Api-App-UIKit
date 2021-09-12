//
//  File.swift
//  Store Search
//
//  Created by Halis  Kara on 10.09.2021.
//

import UIKit
class GradientView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.clear
  }
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    backgroundColor = UIColor.clear
  }
  override func draw(_ rect: CGRect) {
    // 1
    let traits = UITraitCollection.current
    let color: CGFloat = traits.userInterfaceStyle == .light ? 0.314 : 1
    // 2
    let components: [CGFloat] = [
      color, color, color, 0.2,
      color, color, color, 0.4,
      color, color, color, 0.6,
      color, color, color, 1
    ]
    let locations: [CGFloat] = [ 0, 0.5, 0.75, 1 ]
    // 3
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let gradient = CGGradient(
      colorSpace: colorSpace,
      colorComponents: components,
      locations: locations,
      count: 4) // 4
    let x = bounds.midX
    let y = bounds.midY
    let centerPoint = CGPoint(x: x, y: y)
    let radius = max(x, y)
    // 5
    let context = UIGraphicsGetCurrentContext()
    context?.drawRadialGradient(
      gradient!,
      startCenter: centerPoint,
      startRadius: 0,
      endCenter: centerPoint,
      endRadius: radius,
      options: .drawsAfterEndLocation)
  } }
