//
//  MUSTimelineItemControl.swift
//  swift-forte2
//
//  Created by brendon mckinley on 2/07/2015.
//  Copyright (c) 2015 brendon mckinley. All rights reserved.
//

import UIKit
import QuartzCore

class MUSTimelineItemControl: UIControl {
    
    var itemLabel: String? {
        didSet {
            itemLabelNeedsDisplay()
        }
    }
    
    var topLine: CALayer?
    var gradientLayer: CAGradientLayer?
    var innerShadowLayer: CALayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addObserver(self, forKeyPath: "itemLabel", options: .New, context: nil)
        
        layer.masksToBounds = true
        
        gradientLayer = CAGradientLayer()
        gradientLayer!.frame = CGRectMake(0.0, 1.0, layer.bounds.size.width, layer.bounds.size.height - 2.0)
        
        gradientLayer!.colors = [NLAMusicColors.nlaMusicTimelineItemGradientStartColor.CGColor, NLAMusicColors.nlaMusicTimelineItemGradientEndColor.CGColor]
        layer.insertSublayer(gradientLayer!, below: layer)
        
        let topLineLayer: CALayer = CALayer()
        topLineLayer.frame = CGRectMake(0.0, 0.0, layer.frame.size.width, 1.0)
        topLineLayer.backgroundColor = NLAMusicColors.nlaMusicHighlightColor.CGColor
        layer.insertSublayer(topLineLayer, below: layer)
        topLine = topLineLayer
        
        let bottomLineLayer: CALayer = CALayer()
        bottomLineLayer.frame = CGRectMake(0.0, layer.frame.size.height - 1, layer.frame.size.width, 1.0)
        bottomLineLayer.backgroundColor = NLAMusicColors.nlaMusicLowlighColor.CGColor
        
        layer.insertSublayer(bottomLineLayer, below: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
//        if keyPath == "itemLabel" {
//            itemLabelNeedsDisplay()
//        }
//    }
    
    func itemLabelNeedsDisplay() {
        // This method has been intentionally left blank. Subclasses should override it to do something sensible.
    }
    
    override var selected: Bool {
        willSet(newValue) {
            super.selected = self.selected
            if newValue == true {
                print("selected!", terminator: "\n")
                topLine!.backgroundColor = NLAMusicColors.nlaMusicTimelineItemGradientStartColor.CGColor
                // Add an inner shadow
                if innerShadowLayer == nil {
                    let shadowLayer = CAShapeLayer(layer: layer)
                    shadowLayer.frame = bounds
                    shadowLayer.shadowColor = NLAMusicColors.nlaMusicLowlighColor.CGColor
                    shadowLayer.shadowOffset = CGSizeZero
                    shadowLayer.shadowOpacity = 0.75
                    shadowLayer.shadowRadius = 15.0
                    shadowLayer.fillRule = kCAFillRuleEvenOdd
                    
                    innerShadowLayer = shadowLayer
                }
                layer.addSublayer(innerShadowLayer!)
                
                // Darken the gradient
                gradientLayer?.colors = [NLAMusicColors.nlaMusicTimelineSelectedItemGradientStartColor.CGColor, NLAMusicColors.nlaMusicTimelineSelectedItemGradientEndColor.CGColor]
            }
            else {
                // Lighten the top line
                topLine!.backgroundColor = NLAMusicColors.nlaMusicTimelineItemGradientEndColor.CGColor
                
                // Remove the inner shadow
                innerShadowLayer?.removeFromSuperlayer()
                
                // lighten the gradient
                gradientLayer?.colors = [NLAMusicColors.nlaMusicTimelineItemGradientStartColor.CGColor, NLAMusicColors.nlaMusicTimelineItemGradientEndColor.CGColor]
            }
        }
        didSet {
            
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath: "itemLabel")
    }

}

