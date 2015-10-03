//
//  MUSDecadeScoreCollectionViewController.swift
//  swift-forte2
//
//  Created by brendon mckinley on 2/07/2015.
//  Copyright (c) 2015 brendon mckinley. All rights reserved.
//

import UIKit
@IBDesignable
class MUSDecadeScoreCollectionViewController: MUSScoreCollectionViewController, UIPopoverControllerDelegate, MUSComposersTableViewControllerDelegate, MUSAtoZIndexDelegate {
    
    // TODO: add IBOutlets
    // composersButtonItem UIBarButtonItem
    // indexView MUSAtoZIndexView
    
    @IBOutlet weak var toolbarContainerView: UIView!

    let kShowComposersSegueIdentifier = "ShowComposers"

    dynamic var decade: String?
    var composersPopover: UIPopoverController?
    var composersSegmentIndex: Int?
    var composersIndexPath: NSIndexPath?
    var composer:String?
    
    // MARK - Overridden Methods
    
    override func viewDidLoad() {
        addObserver(self, forKeyPath: "decade", options: NSKeyValueObservingOptions.New, context: nil)
        //indexView.delegate = self
        titleLabel.text = ""
        
        toolbarContainerView.layer.cornerRadius = 5.0
        toolbarContainerView.layer.masksToBounds = true
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        //TODO: add when add composer and index views
//        if decade == nil {
//            composersButtonItem.enabled = false
//            indexView.hidden = true
//        }
//        else {
//            composersButonItem.enabled = true
//            indexView.hidden = false
//        }
    }
    
    override var titleString: String? {
        get {
            if let _ = composer {
                return String(format: "%@ (%i items)", composer!, numberOfScoresInCollection!)
            }
            else if let _ = decade {
                let endOfDecade = String(format: "%i", Int(decade!)!)
                let count = dataController?.numberOfScoresInDecade(decade!)
                let title = String(format: "%@ - %@ (%i items)", decade!, endOfDecade, count!)
                return title
            }
            else {
                return ""
            }
        }
        set {
            self.titleString = newValue
        }
    }
    // TODO: remove, I think this is only used by google analytics
//    var trackedViewName: String {
//        get {
//            var viewName: String?
//            if titleString.characters.count < 1 {
//                viewName = "Decade View"
//            }
//            else {
//                viewName = titleString
//            }
//            return viewName!
//        }
//    }
    
    override var numberOfScoresInCollection: Int? {
        get {
            guard let _ = decade else {
                return 0
            }
            if composer != nil {
                return dataController!.numberOfScoresInDecade(decade!, byComposer: composer!)
            }
            else {
                return dataController!.numberOfScoresInDecade(decade!)
            }
        }
        set {
            self.numberOfScoresInCollection = newValue
        }
    }
    
    override func scoreAtIndexPathInCollection(indexPath: NSIndexPath) -> Score {
        if composer == nil {
            return (dataController?.scoreAtIndex(indexPath, inDecade: decade!))!
        }
        else {
            return (dataController?.scoreAtIndex(indexPath, indDecade: decade!, byComposer: composer!))!
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == kShowComposersSegueIdentifier && composersPopover?.popoverVisible == true {
            // Don't show the composers popover if it is already visible, but dismiss it instead
            saveSelections(composersPopover!)
            composersPopover?.dismissPopoverAnimated(true)
            return false
        }
        return super.shouldPerformSegueWithIdentifier(identifier, sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == kShowComposersSegueIdentifier {
            if let navigationController = segue.destinationViewController as? UINavigationController {
                if let composersTableViewController = navigationController.viewControllers[0] as? MUSComposersTableViewController {
                    composersTableViewController.decade = decade
                    composersTableViewController.dataController = dataController
                    composersTableViewController.delegate = self
                    let popoverController = (segue as? UIStoryboardPopoverSegue)?.popoverController
                    composersPopover = popoverController
                    popoverController?.delegate = self
                    
                    // restore the previous selections
                    composersTableViewController.selectedSegmentIndex = composersSegmentIndex
                    composersTableViewController.selectedIndexPath = composersIndexPath
                }
            }
        }
        else if segue.identifier == kOpenScoreSegueIdentifier {
            if let scoreController = segue.destinationViewController as? MUSScoreViewController {
                scoreController.delegate = nil
            }
        }
    }
    
    func dismiss(sender: AnyObject?) {
        // TODO: add
    }
    
    // MARK: - MUSAtoZIndexDelegate protocol methods
    
    func didSelectLetterInIndex(indexView: MUSAtoZIndexView, letter: String) {
        
    }
    
    // MARK: - Popover Methods
    
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        // TODO: add when indexview popover is added
        //saveSelections(popoverController)
    }
    
    // MARK: - Composers Table View Controller Delegate Methods
    
    func composersTableViewControllerDidSelectAllComposers(controller: MUSComposersTableViewController) {
        composer = nil
        titleLabel.text = titleString
        collectionView.reloadData()
        
        // Show the A-Z index
        // TODO: add when indexview popover is added
        //indexView.hidden = false
    }
    
    func composersTableViewController(controller: MUSComposersTableViewController, didSelectComposerWithInfo composerInfo: Dictionary<String, AnyObject>) {
        composer = composerInfo["creator"] as? String
        titleLabel.text = titleString
        collectionView.reloadData()
        
        // It doesn't make sense to have an A - Z index for a single composer, so hide it
        // TODO: add when indexview popover is added
        //indexView.hidden = true
    }
    
    
    // MARK: - Private Methods
    
    func saveSelections(popoverController: UIPopoverController) {
        if let navigationController = popoverController.contentViewController as? UINavigationController {
            if let composersTableViewController = navigationController.topViewController as? MUSComposersTableViewController{
                //TODO: Add when adding composerstablecontroller
                //composersIndexPath = composersTableViewController.selectedIndexPath
                //composersSegmentIndex = composersTableViewController.selectedSegmentIndex
            }
        }
        
    }
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "decade" {
            composer = nil
            composersIndexPath = nil
            composersSegmentIndex = 0
            print("kvo! \(decade)", terminator: "\n")
            // brandingImage.hidden = true
            titleLabel.text = titleString
            //composerButtonItem.enables = true
            collectionView.reloadData()
            let firstItemPath = NSIndexPath(forItem: 0, inSection: 0)
            collectionView.scrollToItemAtIndexPath(firstItemPath, atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: false)
            //indexView.hidden = false
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath: "decade")
    }

}
