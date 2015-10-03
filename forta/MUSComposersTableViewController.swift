//
//  MUSComposersTableViewController.swift
//  swift-forte2
//
//  Created by brendon mckinley on 18/07/2015.
//  Copyright © 2015 brendon mckinley. All rights reserved.
//

import UIKit

class MUSComposersTableViewController: UITableViewController {
    var decade: String?
    var dataController: MUSDataController?
    var delegate: MUSComposersTableViewControllerDelegate?
    var selectedSegmentIndex: Int?
    var selectedIndexPath: NSIndexPath?
    
    var composers: [Dictionary<String, AnyObject>]?
    var composersByName: [Dictionary<String, AnyObject>]?
    var composersByCount: [Dictionary<String, AnyObject>]?
    var maximumNumberByOneComposer: Int?
    
    @IBOutlet var orderSwitcher: UISegmentedControl!
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        navigationItem.titleView = orderSwitcher
        composersByName = dataController?.composersWithMusicPublishedIn(decade!)
        composersByCount = composersByName!.sort { s1, s2 in
            let obj1 = s1
            let obj2 = s2
            let count1: Int = obj1["count"]! as! Int
            let count2: Int = obj2["count"]! as! Int
            return count1 > count2
        }
        maximumNumberByOneComposer = composersByCount![0]["count"]! as? Int
        composers = composersByName
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Restore the selections here, before the
        // table view delegate methods are called
        if let _ = selectedSegmentIndex {
            orderSwitcher.selectedSegmentIndex = selectedSegmentIndex!
        }
        else {
            selectedSegmentIndex = 0
        }
        if orderSwitcher.selectedSegmentIndex == 0 {
            composers = composersByName
        }
        else {
            composers = composersByCount
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if composers!.count < 17 {
            preferredContentSize = CGSizeMake(CGFloat(360.0), CGFloat((composers!.count * 44) + 44))
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return composers!.count
        }
        else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellIdentifier = "AllCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
            if selectedIndexPath == indexPath {
                cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            else {
                cell?.accessoryType = UITableViewCellAccessoryType.None
            }
            return cell!
        }
        else {
            let cellIdentifier = "ComposerCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? MUSComposerCell
            let composerInformation = composers![indexPath.row]
            cell?.maximumNumberOfScores = maximumNumberByOneComposer
            cell?.composerInfo = composerInformation
            
            if selectedIndexPath == indexPath {
                cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            else {
                cell?.accessoryType = UITableViewCellAccessoryType.None
            }
            return cell!
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Update the accessory views.
        if let _ = selectedIndexPath {
            let cell = tableView.cellForRowAtIndexPath(selectedIndexPath!)
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }
        else {
            // Update the selected index path.
            selectedIndexPath = indexPath
            let cell = tableView.cellForRowAtIndexPath(selectedIndexPath!)
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        // Inform the delegate.
        if let _ : MUSComposersTableViewControllerDelegate = delegate {
            if indexPath.section == 0 {
                delegate?.composersTableViewControllerDidSelectAllComposers(self)
            }
            else {
                let composerInfo: NSDictionary = composers![indexPath.row]
                delegate?.composersTableViewController(self, didSelectComposerWithInfo: composerInfo as! Dictionary<String, AnyObject>)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - UI Actions
    
    @IBAction func switchSortOrder(sender: AnyObject) {
        selectedSegmentIndex = orderSwitcher.selectedSegmentIndex
        
        var rowsToMove = [AnyObject]()
        let fromOrder: [Dictionary<String, AnyObject>]?
        let toOrder: [Dictionary<String, AnyObject>]?

        if composers! == composersByName! {
            fromOrder = composersByName
            toOrder = composersByCount
        }
        else {
            fromOrder = composersByCount
            toOrder = composersByName
        }
        
        // Get the index paths for the currently visible rows
        let visibleIndexPaths = tableView.indexPathsForVisibleRows
        
        var firstVisibleComposer = -1
        var lastVisibleComposer = -1
        for indexPath: NSIndexPath in visibleIndexPaths! {
            if indexPath.section == 1 {
                if firstVisibleComposer == -1 {
                    firstVisibleComposer = indexPath.row
                }
                else {
                    lastVisibleComposer = indexPath.row
                }
            }
        }
        
        // Get the composer for the visible rows.
        let visibleComposers = fromOrder![firstVisibleComposer ..< (lastVisibleComposer - firstVisibleComposer)]
        var i = 0
        for composerInfo: Dictionary in visibleComposers {
            // Current index
            let currentIndex = NSIndexPath(forRow: firstVisibleComposer + i, inSection: 1)
            
            // New index
            let newIndex = NSIndexPath(forRow: NSArray(array: toOrder!).indexOfObject(composerInfo) , inSection: 1)
            
            if newIndex != currentIndex {
                let indexChangeDict = ["from": currentIndex, "to": newIndex]
                rowsToMove.append(indexChangeDict)
            }
            i++
        }
        
        // Get the composers who will become visible
        let composersThatWillBecomeVisible = toOrder![firstVisibleComposer ..< (lastVisibleComposer - firstVisibleComposer)]
        i = 0
        for composerInfo: Dictionary in composersThatWillBecomeVisible {
            // Current index
            let currentIndex = NSIndexPath(forRow: NSArray(array: fromOrder!).indexOfObject(composerInfo), inSection: 1)
            
            // New index
            let newIndex = NSIndexPath(forRow: firstVisibleComposer + i, inSection: 1)
            
            if newIndex != currentIndex {
                let indexChangeDict = ["from": currentIndex, "to": newIndex]
                rowsToMove.append(indexChangeDict)
            }
            i++
        }
        
        composers = toOrder
        
        // Update the selected index to account for the reordering of the rows
        if selectedIndexPath?.section == 1 {
            let selectedRowInNewOrder = NSArray(array: toOrder!).indexOfObject(fromOrder![(selectedIndexPath?.row)!])
            let newIndexPath = NSIndexPath(forRow: selectedRowInNewOrder, inSection: 1)
            selectedIndexPath = newIndexPath
        }
        
        // Now actually move the rows
        tableView.beginUpdates()
        for indexChangeDict in rowsToMove {
            tableView.moveRowAtIndexPath(indexChangeDict["from"] as! NSIndexPath, toIndexPath: indexChangeDict["to"] as! NSIndexPath)
        }
        tableView.endUpdates()
    }

}


/**
Classes that wish to be informed when a composer
is selected should implement this delegate protocol.
*/
protocol MUSComposersTableViewControllerDelegate {

    func composersTableViewControllerDidSelectAllComposers(controller: MUSComposersTableViewController)

    func composersTableViewController(controller: MUSComposersTableViewController, didSelectComposerWithInfo composerInfo: Dictionary<String, AnyObject>)
}

