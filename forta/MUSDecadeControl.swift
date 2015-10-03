//
//  MUSDecadeControl.swift
//  swift-forte2
//
//  Created by brendon mckinley on 5/07/2015.
//  Copyright (c) 2015 brendon mckinley. All rights reserved.
//

import UIKit

class MUSDecadeControl: MUSTimelineItemControl {
    
    var label: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label = UILabel(frame: self.bounds)
        label?.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        label?.textAlignment = NSTextAlignment.Center
        label?.textColor = UIColor.blackColor()
        label?.shadowColor = UIColor.whiteColor()
        label?.shadowOffset = CGSizeMake(0.0, 1.0)
        label?.backgroundColor = UIColor.clearColor()
        addSubview(label!)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func itemLabelNeedsDisplay() {
        label?.text = itemLabel!
    }
    
    override var selected: Bool {
        willSet(newValue) {
            if newValue == true {
                label?.shadowColor = NLAMusicColors.nlaMusicTimelineSelectedItemGradientStartColor
            }
            else {
                label?.shadowColor = UIColor.whiteColor()
            }
        }
        didSet {
            
        }
    }
        
}

