//
//  MUSSplitViewController.swift
//  swift-forte2
//
//  Created by brendon mckinley on 2/07/2015.
//  Copyright (c) 2015 brendon mckinley. All rights reserved.
//

import UIKit

class MUSSplitViewController: UIViewController, MUSTimelineViewControllerDelegate {
    
    @IBOutlet var timelinePlaceholder: UIView!
    @IBOutlet var scoreCollectionPlaceholder: UIView!
    
    var timelineController: MUSTimelineViewController?
    var decadeScoreCollectionController: MUSDecadeScoreCollectionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Grab the storyboard
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Grab the Timeline view controller
        timelineController = storyboard.instantiateViewControllerWithIdentifier("Timeline") as? MUSTimelineViewController
        timelineController?.delegate = self
        
        
        // Add the Timeline view controller to self
        addChildViewController(timelineController!)
        timelineController?.didMoveToParentViewController(self)
        timelinePlaceholder.addSubview(timelineController!.view)
        timelinePlaceholder.addSubview(timelineController!.view)
        
        // Add the decade score collection controller
        decadeScoreCollectionController = storyboard.instantiateViewControllerWithIdentifier("DecadeScoreCollection") as? MUSDecadeScoreCollectionViewController
        addChildViewController(decadeScoreCollectionController!)
        decadeScoreCollectionController!.didMoveToParentViewController(self)
        scoreCollectionPlaceholder.addSubview(decadeScoreCollectionController!.view)
        
        // Round the corners
        timelinePlaceholder.layer.cornerRadius = 5.0
        timelinePlaceholder.layer.masksToBounds = true

    }

    override func viewDidAppear(animated: Bool) {
        timelineController?.view.frame = timelinePlaceholder.bounds
        decadeScoreCollectionController?.view.frame = scoreCollectionPlaceholder.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Timeline Controller Delegate Methods
    
    func timelineController(controller: MUSTimelineViewController, didSelectDecade decade: String) {
        decadeScoreCollectionController?.decade = decade
    }
    
    func timelineControllerDidSelectFavourites(controller: MUSTimelineViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let favouritesViewController = storyboard.instantiateViewControllerWithIdentifier("FavouritesController")
        presentViewController(favouritesViewController, animated: true, completion: nil)
    }

}
