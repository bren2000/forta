//
//  MUSFavouritesControl.swift
//  swift-forte2
//
//  Created by brendon mckinley on 4/07/2015.
//  Copyright (c) 2015 brendon mckinley. All rights reserved.
//

import UIKit

class MUSFavouritesControl: MUSTimelineItemControl {
    
    var starImageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        starImageView = UIImageView(image: UIImage(named: "star.png"))
        addSubview(starImageView!)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        starImageView!.center = self.center
    }
}
