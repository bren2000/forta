//
//  MUSTimelineViewController.swift
//  swift-forte2
//
//  Created by brendon mckinley on 2/07/2015.
//  Copyright (c) 2015 brendon mckinley. All rights reserved.
//

import UIKit
import CoreData

class MUSTimelineViewController: UIViewController, UIScrollViewDelegate {
    
    var timelineScrollview: UIView?
    var delegate: MUSTimelineViewControllerDelegate?
    
    // the number of pages the timeline will fill
    let kNumberOfPagesInScrollView = 4
    
    // as the height of each decade is based on the number of scores
    // published in that decade, we need a minimum number so that decades
    // with few scores are still tappable.
    let kMinimumNumberOfScoresPerDecadeForDisplay = 200
    let kMaximumNumberOfScoresPerDecadeForDisplay = 1200
    
    // the height of the favourites section
    let kFavouritesSectionHeight = 88.0
    
    static let kShowIndexSegueIdentifier = "ShowIndex"
    
    var dataController: MUSDataController?
    var selectedDecade: String?
    
    var scrollview: UIScrollView?
    var selectedDecadeControl: MUSDecadeControl?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    @IBAction func showFavourites(sender: AnyObject) {
        // TODO: add when favouurites controller added
    }
    
    func selectDecade(sender: AnyObject) {
        let decadeControl = sender as! MUSDecadeControl
        if let sdc = selectedDecadeControl {
            if sdc == decadeControl {
                return
            }
            selectedDecadeControl?.selected = false
        }
        
        selectedDecadeControl = decadeControl
        decadeControl.selected = true
        
        let decade = decadeControl.itemLabel
        selectedDecade = decade
        
        if delegate != nil {
            delegate?.timelineController(self, didSelectDecade: selectedDecade!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataController = MUSDataController.sharedController
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        createTimeline()
    }
    
    override func viewWillLayoutSubviews() {
        scrollview?.contentSize = CGSizeMake(view.bounds.size.width, view.bounds.size.height * CGFloat(kNumberOfPagesInScrollView))
    }
    
    // draw a view for each decade whose height is relative to
    // the number of items published in that decade
    func createTimeline() {
        var topMargin = kFavouritesSectionHeight
        let leftMargin = 0.0
        var totalNumber = 0
        
        let timelineFrame: CGRect = view.bounds
        scrollview = UIScrollView(frame: timelineFrame)
        scrollview!.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        scrollview?.delegate = self
        scrollview?.scrollEnabled = true
        
        // Add the favourites button
        let favouritesItem: MUSFavouritesControl = MUSFavouritesControl(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: CGFloat(kFavouritesSectionHeight)))
        favouritesItem.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        favouritesItem.addTarget(self, action: "showFavourites:", forControlEvents: UIControlEvents.TouchDown)
        scrollview!.addSubview(favouritesItem)
        
        
        if let decades = dataController?.decadesInWhichMusicWasPublished() {
            for dict in decades {
                let count = dict.valueForKey("count") as! Int
                if count > kMaximumNumberOfScoresPerDecadeForDisplay {
                    totalNumber += kMaximumNumberOfScoresPerDecadeForDisplay
                }
                else if count > kMinimumNumberOfScoresPerDecadeForDisplay {
                    totalNumber += count
                } else {
                    totalNumber += kMinimumNumberOfScoresPerDecadeForDisplay
                }
            }
            
            var decadeIndex = 0
            
            for dict in decades {
                let decade = dict.valueForKey("date") as! String
                if !decade.isEmpty {
                    var numberInDecade = dict.valueForKey("count") as! Int
                    if numberInDecade > kMaximumNumberOfScoresPerDecadeForDisplay {
                        numberInDecade = kMaximumNumberOfScoresPerDecadeForDisplay
                    }
                    else if numberInDecade < kMinimumNumberOfScoresPerDecadeForDisplay {
                        numberInDecade = kMinimumNumberOfScoresPerDecadeForDisplay
                    }
                    let h1 = Double(numberInDecade) / Double(totalNumber)
                    let h2 = Double(self.view.bounds.size.height) * Double(kNumberOfPagesInScrollView)
                    let h3 = h2 - Double(kFavouritesSectionHeight)
                    let h4 = h1 * h3
                    let height = h4
                    let frame = CGRect(x: leftMargin, y: topMargin, width: Double(self.view.frame.size.width), height: height)
                    
                    let decadeControl = MUSDecadeControl(frame: frame)
                    decadeControl.itemLabel = decade
                    decadeControl.addTarget(self, action: "selectDecade:", forControlEvents: .TouchDown)
                    decadeControl.autoresizingMask = UIViewAutoresizing.FlexibleWidth
                    
                    scrollview?.addSubview(decadeControl)
                    topMargin += height
                }
                decadeIndex++
            }

        }

        timelineScrollview = scrollview
        view.addSubview(scrollview!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

protocol MUSTimelineViewControllerDelegate {
    func timelineController(controller: MUSTimelineViewController, didSelectDecade decade: String)
    func timelineControllerDidSelectFavourites(controller: MUSTimelineViewController)
}
