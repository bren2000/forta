//
//  MUSDataController.swift
//  swift-forte2
//
//  Created by brendon mckinley on 6/07/2015.
//  Copyright (c) 2015 brendon mckinley. All rights reserved.
//

import Foundation
import CoreData

/**
Provides access to the sheet music collection.
*/
class MUSDataController: NSObject {
    
    let kFavouritesKey = "favourite-scores"
    let kMaximumNumberOfPagesToCache = 10
    
    var model: NSManagedObjectModel?
    var coordinator: NSPersistentStoreCoordinator?
    var context: NSManagedObjectContext?
    
    var cachedDecades = [AnyObject]()
    var cachedScores = [Score]()
    var decadeOfCachedScores: String?
    var cachedScoresByComposer = [Score]()
    var composerOfCachedScores:String?
    
    // Create the singleton
    static let sharedController = MUSDataController()
    
    override init() {
        super.init()
        
        if context == nil {
            // Create the managed object model
            model = NSManagedObjectModel.mergedModelFromBundles(nil)
            
            // Create the persistent store coordinator
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model!)
            
            // Create the persistent store itself (if it is not already there)
            
            // copy the core-data database to the documents directory if it isn't already there
            let expandTilde = true
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, expandTilde)
            let documentPath: String = paths[0] as String
            //let dataStorePath = documentPath.stringByAppendingPathComponent("data2.sqlite")
            //let storeURL = NSURL(fileURLWithPath: dataStorePath)
            
            // --
            let dataStorePath = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let storeURL = dataStorePath.URLByAppendingPathComponent("data2.sqlite")
            // --
            
            var isDir = ObjCBool(false)
            let defaultManager: NSFileManager = NSFileManager()

            if (!defaultManager.fileExistsAtPath("\(dataStorePath)", isDirectory: &isDir) && isDir.boolValue == false) {
                let path = NSURL(fileURLWithPath: documentPath)
                do {
                    try defaultManager.createDirectoryAtURL(path, withIntermediateDirectories: true, attributes: nil)
                } catch let error1 as NSError {
                    print(error1, terminator: "\n")
                }
    
                if let bundleURL = NSBundle.mainBundle().URLForResource("data2", withExtension: "sqlite"){
                    do {
                        try NSFileManager.defaultManager().copyItemAtURL(bundleURL, toURL: storeURL)
                    } catch let error as NSError {
                        print(error, terminator: "\n")
                    }
                }
                else {
                    print("error doing something")
                }
            }
            else {
                //print(defaultManager.fileExistsAtPath(dataStorePath, isDirectory: &isDir))
            }
            do {
                try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            } catch let error as NSError{
                print("\(error)")
            }
            
            // Create the context
            context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
            context!.persistentStoreCoordinator = coordinator
            
            // Get the 'score' entity from the model and specify the sort order for the
            // 'orderedPages' fetched property
            let scoreEntityDescription = NSEntityDescription.entityForName("Score", inManagedObjectContext: context!)
            let orderedPagesDescription = scoreEntityDescription?.propertiesByName["orderedPages"] as! NSFetchedPropertyDescription
            
            let fetchRequest = orderedPagesDescription.fetchRequest
            fetchRequest?.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        }
    }
    
    /**
    Returns the index path of the first score in the collection
    whose sort title starts with the given letter or nil of there
    was no score whose sort title starts with the given letter.
    */
    func indexOfFirstScoreWithLetter(letter: String, inDecade decade: String) -> NSIndexPath? {
        var found = false
        var indexPath: NSIndexPath?
        var i = 0
        
        for score: Score in cachedScores {
            if score.sortTitle.lowercaseString.hasPrefix(letter.lowercaseString) {
                found = true
                break
            }
            i++
        }
        
        if found {
            indexPath = NSIndexPath(forItem: i - 1, inSection: 0)
        }
        
        return indexPath
    }
    
    /**
    Returns the score for the given index path in the given decade.
    */
    func scoreAtIndex(indexPath: NSIndexPath, inDecade decade: String) -> Score {
        if let _ = decadeOfCachedScores {
            if (decadeOfCachedScores == decade) && (!cachedScores.isEmpty) {
                return cachedScores[indexPath.row]
            }
        }
        
        let scoresFetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Score")
        
        // Sort order
        let titleSortDescriptor = NSSortDescriptor(key: "sortTitle", ascending: true, selector: "caseInsensitiveCompare:")
        scoresFetchRequest.sortDescriptors = [titleSortDescriptor]
        
        // Only get scores for the given decade
        let decadePredicate: NSPredicate = NSPredicate(format: "%K == %@", argumentArray: ["date", decade])
        scoresFetchRequest.predicate = decadePredicate
        
        do {
            let scores = try context!.executeFetchRequest(scoresFetchRequest)
            
            // We're caching scores for a given decade (with no composer)
            // so forget the previously cached scores with a given composer
            composerOfCachedScores = nil
            cachedScoresByComposer = []
            cachedScores = scores as! [Score]
            
            decadeOfCachedScores = decade
            return cachedScores[indexPath.row]
        } catch let error as NSError  {
            print(error, terminator: "\n")
            return Score()
        }
    }
    
    /**
    Returns the score for the given index path in the given decade by the given composer.
    */
    func scoreAtIndex(indexPath: NSIndexPath, indDecade decade: String, byComposer composer: String) -> Score {
        if let _ = decadeOfCachedScores {
            if let _ = composerOfCachedScores {
                if decadeOfCachedScores == decade && composerOfCachedScores == composer {
                    return cachedScoresByComposer[indexPath.row]
                }
            }
        }
        let scoresFetchRequest = NSFetchRequest(entityName: "Score")
        
        // Sort order
        let titleSortDescriptor = NSSortDescriptor(key: "sortTitle", ascending: true, selector: "caseInsensitiveCompare:")
        scoresFetchRequest.sortDescriptors = [titleSortDescriptor]
        
         // Only get scores for the given decade and composer
        let decadePredicate = NSPredicate(format: "date == %@ AND creator == %@", argumentArray: [decade, composer])
        scoresFetchRequest.predicate = decadePredicate
        do {
            let scores = try context!.executeFetchRequest(scoresFetchRequest) as! [Score]
            // We're caching scores for a given decade (with a given composer)
            // so forget the previously cached scores without a given composer
            cachedScores = []
            cachedScoresByComposer = scores
            decadeOfCachedScores = decade
            composerOfCachedScores = composer
            return cachedScoresByComposer[indexPath.row]
        } catch let error as NSError  {
            print(error, terminator: "\n")
            return Score()
        }
    }
    
// MARK: - Decades
    
    func fetchDecades() -> [AnyObject]? {
        let fetchRequest = NSFetchRequest(entityName: "Score")
        let scoreEntityDescription = NSEntityDescription.entityForName("Score", inManagedObjectContext: context!)
        let dateAttributeDescription: NSAttributeDescription = (scoreEntityDescription?.attributesByName["date"])!
        let keyPathExpression = NSExpression(forKeyPath: "title")
        let countExpression = NSExpression(forFunction: "count:", arguments: [keyPathExpression])
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "count"
        expressionDescription.expression = countExpression
        expressionDescription.expressionResultType = NSAttributeType.Integer32AttributeType
        
        fetchRequest.propertiesToFetch = [dateAttributeDescription, expressionDescription]
        fetchRequest.propertiesToGroupBy = [dateAttributeDescription]
        fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
        
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [dateSortDescriptor]
        
        do {
            let results = try context!.executeFetchRequest(fetchRequest)
            cachedDecades = results
            return results
        } catch let error as NSError {
            print(error, terminator: "\n")
        }
        return nil
    }
    
    /**
    Returns an array of dictionaries with information
    about the music that was published in each decade.
    The dictionaries contain two keys:
    - decade (a String with the decade in which the music was published)
    - count (the number of scores in the collection for the given decade).
    */
    func decadesInWhichMusicWasPublished() -> [AnyObject]? {
        if !cachedDecades.isEmpty {
            return cachedDecades
        }
        let results = fetchDecades()
        return results
    }
    
    /**
    Returns the number of scores published in the given decade.
    */
    func numberOfScoresInDecade(decade: String) ->Int {
        let decades: [AnyObject]
        if !cachedDecades.isEmpty {
            decades = cachedDecades
        }
        else {
            decades = fetchDecades()!
        }
        for dict in decades {
            if dict.valueForKey("date") as? String == decade {
                return dict.valueForKey("count") as! Int
            }
        }
        return 0
    }
    
    /**
    Returns the number of scores published in the given decade by the given composer.
    */
    func numberOfScoresInDecade(decade: String, byComposer composer: String) -> Int {
        let fetchrequest = NSFetchRequest(entityName: "Score")
        
        let scoreEntityDescription = NSEntityDescription.entityForName("Score", inManagedObjectContext: context!)
        let dateAttributeDescription: NSAttributeDescription = (scoreEntityDescription!.attributesByName["date"])!
        let composerAttributeDescription: NSAttributeDescription = (scoreEntityDescription!.attributesByName["creator"])!
        let keyPathExpression = NSExpression(forKeyPath: "title")
        let countExpression = NSExpression(forFunction: "count:", arguments: [keyPathExpression])
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "count"
        expressionDescription.expression = countExpression
        expressionDescription.expressionResultType = NSAttributeType.Integer32AttributeType
        
        let decadeAndComposerPredicate = NSPredicate(format: "date == %@ AND creator == %@", argumentArray: [decade, composer])
        
        fetchrequest.propertiesToFetch = [dateAttributeDescription, expressionDescription, composerAttributeDescription]
        fetchrequest.propertiesToGroupBy = [dateAttributeDescription, composerAttributeDescription]
        fetchrequest.resultType = NSFetchRequestResultType.DictionaryResultType
        fetchrequest.predicate = decadeAndComposerPredicate
        
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchrequest.sortDescriptors = [dateSortDescriptor]
        
        let results: [AnyObject]?
        do {
            results = try context?.executeFetchRequest(fetchrequest)
        } catch _ {
            results = nil
        }
        
        // There should be a single row
        assert(results?.count == 1, "results = \(results?.count)")
        
        let resultDict = results?[0]
        let count: Int = resultDict?.valueForKey("count") as! Int
        
        //return count
        return count
    }
    
// MARK: - Composers
    
    func composersWithMusicPublishedIn(decade: String) -> [Dictionary<String, AnyObject>]? {
        let fetchrequest = NSFetchRequest(entityName: "Score")
        
        let scoreEntityDescription = NSEntityDescription.entityForName("Score", inManagedObjectContext: context!)
        let composerAttributeDescription: NSAttributeDescription = (scoreEntityDescription!.attributesByName["creator"])!
        let keyPathExpression = NSExpression(forKeyPath: "title")
        let countExpression = NSExpression(forFunction: "count:", arguments: [keyPathExpression])
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "count"
        expressionDescription.expression = countExpression
        expressionDescription.expressionResultType = NSAttributeType.Integer32AttributeType
        
        let predicate = NSPredicate(format: "creator.length > 0 AND date == %@", argumentArray: [decade])
        
        fetchrequest.predicate = predicate
        fetchrequest.propertiesToFetch = [composerAttributeDescription, expressionDescription]
        fetchrequest.propertiesToGroupBy = [composerAttributeDescription]
        fetchrequest.resultType = NSFetchRequestResultType.DictionaryResultType
        
        let composerSortDescriptor = NSSortDescriptor(key: "creator", ascending: true)
        fetchrequest.sortDescriptors = [composerSortDescriptor]
        
        var results: [Dictionary<String, AnyObject>]?
        do {
            guard let results = try context?.executeFetchRequest(fetchrequest) as? [Dictionary<String, AnyObject>] else {
                return nil
            }
            return results
        } catch _ {
            return nil
        }
    }
    
// MARK: - Favourites
    
    func numberOfFavouriteScores() -> Int {
        return 22
    }
    
    func scoreAtIndexInFavourites(index: Int) -> Score {
        return Score()
    }
    
    func fetchIdentifiersOfFavourites() -> [AnyObject] {
        return ["sss"]
    }
    
    func isScoreMarkedAsFavourite(score: Score) -> Bool {
        return false
    }
    
    func markScore(score: Score, asFavorite isFavourite: Bool) {
        
    }
    
}






































