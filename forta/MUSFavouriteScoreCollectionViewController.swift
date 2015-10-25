//
//  MUSFavouriteScoreCollectionViewController.swift
//  swift-forte2
//
//  Created by brendon mckinley on 18/07/2015.
//  Copyright © 2015 brendon mckinley. All rights reserved.
//

import UIKit

class MUSFavouriteScoreCollectionViewController: MUSScoreCollectionViewController, MUSScoreViewControllerDelegate {
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
        
    func numberOfScoreInCollection() -> Int{
        return dataController!.numberOfFavouriteScores()
    }
    
    override func scoreAtIndexPathInCollection(indexPath: NSIndexPath) -> Score {
        return (dataController?.scoreAtIndexInFavourites(indexPath.row))!
    }
    
   // MARK: Score View Controller Delegate Methods.
    func scoreViewController(controller: MUSScoreViewController, didDismissScore score: Score, atPageNumber pageNumber: Int) {
        let lastOpenedPageNumberKey = "\(score.identifier)-last-opened-page"
        NSUserDefaults.standardUserDefaults().setInteger(pageNumber, forKey: lastOpenedPageNumberKey)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let scoreController = segue.destinationViewController as? MUSScoreViewController {
            scoreController.delegate = self
            let lastOpenedPageNumberKey = "\(selectedScore?.identifier)-last-opened-page"
            let lastOpenedPageNumber = NSUserDefaults.standardUserDefaults().integerForKey(lastOpenedPageNumberKey)
            scoreController.initialPageNumber = lastOpenedPageNumber
        }
        super.prepareForSegue(segue, sender: sender)
    }

}
