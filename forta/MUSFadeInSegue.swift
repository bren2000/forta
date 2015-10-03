//
//  MUSFadeInSegue.swift
//  swift-forte2
//
//  Created by brendon mckinley on 6/07/2015.
//  Copyright (c) 2015 brendon mckinley. All rights reserved.
//

import UIKit

class MUSFadeInSegue: UIStoryboardSegue {
    
    override func perform() {
        if let source = sourceViewController as UIViewController? {
            if let destination = destinationViewController as UIViewController? {
                UIGraphicsBeginImageContext(source.view.bounds.size)
                source.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
                let sourceImage = UIGraphicsGetImageFromCurrentImageContext()
                let sourceImageView = UIImageView(image: sourceImage)
                UIGraphicsEndImageContext()
                source.presentViewController(destination, animated: false, completion: nil)
                destination.view.addSubview(sourceImageView)
                let interval: NSTimeInterval = 0.25
                UIView.animateWithDuration(interval,
                    animations: {
                        sourceImageView.alpha = 0.0
                    },
                    completion: { (Bool) -> Void in
                        sourceImageView.removeFromSuperview()
                })
            }
        }
    }
    
}

