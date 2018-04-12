//
//  Image+Extensions.swift
//  Everchulo
//
//  Created by ATEmobile on 18/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit
import CoreData

// Image Extensions
extension Image {

    // Create
    static func create(into givenCtx: NSManagedObjectContext? = nil, for note: Note, data: NSData, topRatio: CGFloat, leftRatio: CGFloat, heightRatio: CGFloat, rotation: CGFloat, commit: Bool? = false) -> Image? {
        let ctx: NSManagedObjectContext = givenCtx ?? DataManager.shared.viewContext
        
        /* insert */
        guard let nsObj = NSEntityDescription.insertNewObject(forEntityName: "Image", into: ctx) as? Image else { return(nil) }
        
        /* set */
        nsObj.note  = note
        nsObj.data  = data
        
        /* set */
        nsObj.topRatio      = Float(topRatio)
        nsObj.leftRatio     = Float(leftRatio)
        nsObj.heightRatio   = Float(heightRatio)
        nsObj.rotation      = Float(rotation)
        
        /* set */
        nsObj.frontIndex    = Int64(note.images?.count ?? 0)
        
        /* check */
        if (commit!) {
            nsObj.save()
        }
        
        /* done */
        return(nsObj)
    }
}

// MARK: - Instance Methods
extension Image {
    
    // Save
    func save(from givenCtx: NSManagedObjectContext? = nil) {
        return(DataManager.save(from: givenCtx))
    }
    
    // Delete
    func delete(from givenCtx: NSManagedObjectContext? = nil, commit: Bool? = false) {
        return(DataManager.delete(from: givenCtx, object: self, commit: commit))
    }
}

// MARK: - Proxies
extension Image {
    var proxyForComparison: Int64 {
        return(self.frontIndex)
    }
}

// MARK: - Comparable
extension Image: Comparable {
    public static func <(lhs: Image, rhs: Image) -> Bool {
        return(lhs.proxyForComparison < rhs.proxyForComparison)
    }
}
