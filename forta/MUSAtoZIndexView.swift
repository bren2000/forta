//
//  MUSAtoZIndexView.swift
//  swift-forte2
//
//  Created by brendon mckinley on 5/07/2015.
//  Copyright (c) 2015 brendon mckinley. All rights reserved.
//

import UIKit
import ObjectiveC

class MUSAtoZIndexView : UIView {
    
    var delegate: MUSAtoZIndexDelegate?
    let letters = ["A", "B", "C", "D", "E", "F", "G", "H",
                    "I", "J", "K", "L", "M", "N", "O", "P",
                    "Q", "R", "S", "T", "U", "V", "W", "X",
                    "Y", "Z"]
    let kPadding: CGFloat = 22.0
    var lastLetter: String?
    var letterViews = [UILabel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 20.0
        layer.backgroundColor = UIColor.clearColor().CGColor
        lastLetter = nil
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if letterViews.isEmpty {
            for index in 1...26 {
                let letterLabel: UILabel = UILabel()
                letterLabel.textAlignment = NSTextAlignment.Center
                letterLabel.text = letters[index]
                letterLabel.textColor = UIColor.whiteColor()
                letterLabel.backgroundColor = UIColor.clearColor()
                letterViews.append(letterLabel)
                addSubview(letterLabel)
            }
            for index in 1...26 {
                let letterLabel: UILabel = letterViews[index]
                let height = (frame.size.height - CGFloat(2.0) * kPadding) / 26.0
                letterLabel.frame = CGRect(x: CGFloat(0.0), y: (CGFloat(index) * height) + kPadding, width: frame.size.width, height: height)
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        notifyDelegateOfTouchedLetterWithTouches(touches)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        notifyDelegateOfTouchedLetterWithTouches(touches)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        layer.backgroundColor = UIColor.clearColor().CGColor
    }
    
    func notifyDelegateOfTouchedLetterWithTouches(touches: NSSet) {
        layer.backgroundColor = UIColor(white: 1.0, alpha: 0.5).CGColor
        
        // get a touch
        let touch: UITouch = touches.anyObject() as! UITouch
        
        // get the position of the touch within the view
        let touchPoint: CGPoint = touch.locationInView(self)
        let touchHeight: CGFloat = fmax(touchPoint.y, CGFloat(0.0))

        // get the closest letter
        var letter: String = ""
        for index in 0...letterViews.count {
            let letterLabel: UILabel = letterViews[index]
            letter = letterLabel.text!
            if touchHeight > letterLabel.frame.origin.y && touchHeight < letterLabel.frame.origin.y + letterLabel.frame.size.height {
                break
            }
        }
        if letter.isEmpty {
            if lastLetter != letter {
                lastLetter = letter
                if delegate!.conformsToProtocol(MUSAtoZIndexDelegate) {
                    delegate!.didSelectLetterInIndex(self, letter: letter)
                }
            }
        }
    }
    
}

@objc protocol MUSAtoZIndexDelegate: NSObjectProtocol {
    func didSelectLetterInIndex(indexView: MUSAtoZIndexView, letter: String)
}

