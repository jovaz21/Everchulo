//
//  DataManager.swift
//  Everchulo
//
//  Created by ATEmobile on 19/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Environment (Unit Testing | Production)
enum DataManagerEnvironment: String {
    case testing
    case production
}

// MARK: - DataManager
final class DataManager: NSObject { static let persistentContainerName = "Everchulo"

    /* Environment */
    private static var env: DataManagerEnvironment = .production
    public static func setenv(value: DataManagerEnvironment) { DataManager.env = value }
    
    // Shared Singleton
    static let shared = DataManager()
    override private init() { super.init()
        
        /* check */
        if (DataManager.env == .testing) {
            return
        }
        
        /* check */
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if (appDelegate == nil) { // No Default PersistentContainer
            return
        }
        
        /* set */
        self.persistentContainer = appDelegate!.persistentContainer
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    // Main View Object Context
    var viewContext:NSManagedObjectContext {
        return(self.persistentContainer.viewContext)
    }
    
    // Private Background Object Context
    var backgroundContext:NSManagedObjectContext {
        return(self.persistentContainer.newBackgroundContext())
    }
    
    // Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: DataManager.persistentContainerName)
        
        /* Unit Testing Stuff */
        if (DataManager.env == .testing) {
            
            /* set */
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            description.shouldAddStoreAsynchronously = false // Make it simpler in test env
            
            /* set */
            container.persistentStoreDescriptions = [description]
        }
        
        /* Load App Model Stores */
        container.loadPersistentStores(completionHandler: {(storeDescription, error) in
            print("Persistent Stores Cargados, ", storeDescription)
            if let err = error {
                print(err)
            }
        })
        
        /* set */
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        /* done */
        return(container)
    }()
}
