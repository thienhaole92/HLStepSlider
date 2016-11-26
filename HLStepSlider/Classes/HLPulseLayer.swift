//
//  HLPulseLayer.swift
//  HLStepSlider
//
//  Created by OSXVN on 11/26/16.
//  Copyright © 2016 HaoLe. All rights reserved.
//

import UIKit
import QuartzCore

class HLPulseLayer: CAShapeLayer {
    
    override init() {
        super.init()
        self.initPulseLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initPulseLayer()
    }
    
    func initPulseLayer() {
        self.path = UIBezierPath(arcCenter: CGPoint(x:0, y:0), radius: 30, startAngle: 0.0, endAngle: CGFloat(2.0 * M_PI), clockwise: true).cgPath
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = 0.0
        scaleAnimation.toValue = 1.0
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        self.fillColor = UIColor(red: 0.193, green: 0.577, blue: 0.775, alpha: 1.0).cgColor
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [scaleAnimation, opacityAnimation]
        animationGroup.duration = 2.0
        animationGroup.repeatCount = HUGE
        self.add(animationGroup, forKey: "pulse")
    }

}
