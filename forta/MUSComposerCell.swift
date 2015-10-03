//
//  MUSComposerCell.swift
//  swift-forte2
//
//  Created by brendon mckinley on 5/07/2015.
//  Copyright (c) 2015 brendon mckinley. All rights reserved.
//

import UIKit

class MUSComposerCell: UITableViewCell {
    
    /**
    A dictionary containing information about the
    composer. The dictionary should contain two values:
    - creator, a String with the composer's name
    - count, an int representing the number of scores for
    the composer in the given context (eg decade).
    */
    dynamic var composerInfo: NSDictionary?
    
    /**
    The maximum number of scores created by any composer
    in the given context (eg decade) so this cell can
    represent the current composer's count as a percentage
    of the largest count.
    */
    var maximumNumberOfScores: Int?
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var composerLabel: UILabel!
    
    var barView: UIView?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialise()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialise()
    }
    
    func initialise() {
        addObserver(self, forKeyPath: "composerInfo", options: NSKeyValueObservingOptions.New, context: nil)
        let view: UIView = UIView(frame: self.bounds)
        let barView = UIView(frame: CGRectZero)
        barView.backgroundColor = UIColor(red: 236.0/255, green: 229.0/255, blue: 255.0/255, alpha: 0.85)
        self.barView = barView
        view.addSubview(barView)
        backgroundView = view
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "composerInfo" {
            composerLabel.text = composerInfo!.valueForKey("creator") as? String
            let count = composerInfo!.valueForKey("count") as! Int
            countLabel.text = String(count)
            
            let percent = Double(count) / Double(maximumNumberOfScores!)
            let barWidth = CGFloat(percent) * frame.size.width
            barView?.frame = CGRectMake(0.0, 0.0, barWidth, frame.size.height)
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath: "composerInfo")
    }
    
}
