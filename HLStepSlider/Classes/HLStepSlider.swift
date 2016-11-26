//
//  HLStepSlider.swift
//  HLStepSlider
//
//  Created by OSXVN on 11/26/16.
//  Copyright © 2016 HaoLe. All rights reserved.
//

import UIKit

@IBDesignable
open class HLStepSlider: UIControl {
    @IBInspectable public var minimumValue: Int = 0
    @IBInspectable public var maximumValue: Int = 4
    @IBInspectable public var value: Int = 2 {
        didSet {
            self.sendActions(for: .valueChanged)
        }
    }
    
    //track properties
    let trackLayer = CALayer()
    @IBInspectable public var trackHeight: CGFloat = 2
    @IBInspectable public var trackColor: UIColor = UIColor.darkGray
    
    //tick properties
    @IBInspectable public var tickHeight: CGFloat = 8
    @IBInspectable public var tickWidth: CGFloat = 8
    @IBInspectable public var tickRadius: CGFloat = 4
    @IBInspectable public var tickColor = UIColor.darkGray
    
    //thumb properties
    lazy var thumbLayer : CAShapeLayer = {
        let layer = CAShapeLayer()
        let pulse = HLPulseLayer()
        pulse.position = CGPoint(x: 15.0, y: 15.0)
        layer.addSublayer(pulse)
        return layer
    }()
    @IBInspectable public var thumbFillColor = UIColor(red: 0.193, green: 0.577, blue: 0.775, alpha: 1.0)
    @IBInspectable public var thumbDimension: CGFloat = 30.0
    @IBInspectable public var thumbStrokeColor: UIColor = UIColor(red: 0.193, green: 0.577, blue: 0.775, alpha: 1.0)
    
    @IBInspectable public var displayShadow: Bool = false
    
    var trackWidth: CGFloat {
        return self.bounds.size.width - self.thumbDimension
    }
    
    var trackOffset: CGFloat {
        return (self.bounds.size.width - self.trackWidth) / 2
    }
    
    var stepWidth: CGFloat {
        return self.trackWidth / CGFloat(self.maximumValue)
    }
    
    var numberOfSteps: Int {
        return self.maximumValue - self.minimumValue + 1
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    fileprivate func commonInit() {
        self.trackLayer.backgroundColor = self.trackColor.cgColor
        self.layer.addSublayer(trackLayer)
        
        self.thumbLayer.backgroundColor = UIColor.clear.cgColor
        self.thumbLayer.fillColor = self.thumbFillColor.cgColor
        self.thumbLayer.strokeColor = self.thumbStrokeColor.cgColor
        self.thumbLayer.lineWidth = 0.5
        self.thumbLayer.frame = CGRect(x: 0, y: 0, width: self.thumbDimension, height: self.thumbDimension)
        self.thumbLayer.path = UIBezierPath(ovalIn: self.thumbLayer.bounds).cgPath
        
        // Shadow
        if self.displayShadow {
            self.thumbLayer.shadowOffset = CGSize(width: 0, height: 2)
            self.thumbLayer.shadowColor = UIColor.black.cgColor
            self.thumbLayer.shadowOpacity = 0.3
            self.thumbLayer.shadowRadius = 2
            self.thumbLayer.contentsScale = UIScreen.main.scale
        }
        
        self.layer.addSublayer(self.thumbLayer)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        //setup track layer
        var rect = self.bounds
        rect.origin.x = self.trackOffset
        rect.origin.y = (rect.size.height - self.trackHeight) / 2
        rect.size.height = self.trackHeight
        rect.size.width = self.trackWidth
        self.trackLayer.frame = rect
        
        //setup thumb layer
        let center = CGPoint(x: self.trackOffset + CGFloat(self.value) * self.stepWidth, y: self.bounds.midY)
        let thumbRect = CGRect(x: center.x - self.thumbDimension / 2, y: center.y - self.thumbDimension / 2, width: self.thumbDimension, height: self.thumbDimension)
        self.thumbLayer.frame = thumbRect
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        for index in 0..<self.numberOfSteps {
            let x = self.trackOffset + CGFloat(index) * self.stepWidth - 0.5 * self.tickWidth
            let y = self.bounds.midY - self.tickHeight * 0.5
            if let ctx = UIGraphicsGetCurrentContext() {
                let rectangle = CGRect(x: x, y: y, width: self.tickWidth, height: self.tickHeight)
                //clip the tick
                let tickPath = UIBezierPath(rect: rectangle).cgPath
                ctx.setFillColor(self.tickColor.cgColor)
                ctx.addPath(tickPath)
                ctx.fillPath()
            }
        }
    }
    
    
    //MARK: - Touch
    var previousLocation: CGPoint!
    var dragging = false
    var originalValue: Int!
    
    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchLocation = touch.location(in: self)
        self.originalValue = self.value
        if self.thumbLayer.frame.contains(touchLocation) {
            self.dragging = true
        }else {
            self.dragging = false
        }
        self.previousLocation = touchLocation
        return self.dragging
    }
    
    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchLocation = touch.location(in: self)
        let deltaLocation = touchLocation.x - self.previousLocation.x
        let deltaValue = self.deltaValue(deltaLocation)
        if deltaLocation < 0 {
            //move to left
            self.value = self.clipValue(self.originalValue - deltaValue)
        }else {
            //move to right
            self.value = self.clipValue(self.originalValue + deltaValue)
        }
        self.setNeedsLayout()
        return true
    }
    
    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        self.previousLocation = nil
        self.originalValue = nil
        self.dragging = false
        self.sendActions(for: .valueChanged)
    }
    
    //MARK: - Helper
    fileprivate func deltaValue(_ deltaLocation: CGFloat) -> Int {
        return Int(round(fabs(deltaLocation) / self.stepWidth))
    }
    
    fileprivate func clipValue(_ value: Int) -> Int {
        return min(max(value, self.minimumValue), self.maximumValue)
    }
    
}
