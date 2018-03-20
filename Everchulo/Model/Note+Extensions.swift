//
//  Note+Extensions.swift
//  Everchulo
//
//  Created by ATEmobile on 18/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import Foundation
import CoreData

// MARK: - CRUD Helpers
extension Note {
    
    // List All
    static func listAll(from givenCtx: NSManagedObjectContext? = nil, returnsObjectsAsFaults: Bool? = true) -> [Note] {
        let ctx: NSManagedObjectContext = givenCtx ?? DataManager.shared.viewContext
        
        /* set */
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = returnsObjectsAsFaults!
        
        /* fetch */
        let res = try? ctx.fetch(fetchRequest)
        return(res ?? [Note]())
    }
    
    // FindById
    static func findById(from givenCtx: NSManagedObjectContext? = nil, objectID oid: NSManagedObjectID) -> Note? {
        let ctx: NSManagedObjectContext = givenCtx ?? DataManager.shared.viewContext
        return(ctx.object(with: oid) as? Note)
    }
    
    // FindBy Text
    static func findByText(from givenCtx: NSManagedObjectContext? = nil, text: String) -> Note? {
        let ctx: NSManagedObjectContext = givenCtx ?? DataManager.shared.viewContext
        
        /* set */
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "title contains[c] %@", text),
            NSPredicate(format: "content contains[c] %@", text),
            NSPredicate(format: "tags contains[c] %@", text)
        ])
        
        /* fetch */
        guard let resArray = try? ctx.fetch(fetchRequest) else { return(nil) }
        return(resArray.first)
    }
    
    // Create
    static func create(into givenCtx: NSManagedObjectContext? = nil, title givenTitle: String? = nil, content: String, tags: String? = nil, commit: Bool? = false) -> Note? {
        let ctx: NSManagedObjectContext = givenCtx ?? DataManager.shared.viewContext
        
        /* insert */
        guard let nsObj = NSEntityDescription.insertNewObject(forEntityName: "Note", into: ctx) as? Note else { return(nil) }
        
        /* check */
        if (givenTitle != nil) {
            nsObj.title = givenTitle
        }
        else {
            nsObj.title = content
        }
        
        /* set */
        nsObj.content    = content
        nsObj.tags       = tags
        
        /* set */
        nsObj.createdTimestamp   = Date().timeIntervalSince1970
        nsObj.updatedTimestamp   = 0
        nsObj.alarmTimestamp     = 0
        
        /* check */
        if (commit!) {
            nsObj.save()
        }
        
        /* done */
        return(nsObj)
    }
    
    // Delete
    fileprivate static func delete(from givenCtx: NSManagedObjectContext? = nil, object: NSManagedObject, commit: Bool? = false) {
        let ctx: NSManagedObjectContext = givenCtx ?? DataManager.shared.viewContext
        
        /* delete */
        ctx.delete(object)
        
        /* check */
        if (commit!) {
            Note.save()
        }
    }
    static func deleteAll(from givenCtx: NSManagedObjectContext? = nil, commit: Bool? = false) {
        let ctx: NSManagedObjectContext = givenCtx ?? DataManager.shared.viewContext
        
        /* delete */
        Note.listAll(from: ctx).forEach({(obj: Note) in
            obj.delete(from: ctx)
        })
        
        /* check */
        if (commit!) {
            Note.save()
        }
    }
    
    // Save
    static func save(from givenCtx: NSManagedObjectContext? = nil) {
        let ctx: NSManagedObjectContext = givenCtx ?? DataManager.shared.viewContext
        if (!ctx.hasChanges) {
            return
        }
        do {
            try ctx.save()
        } catch { print("Save error \(error)") }
    }
}

// MARK: - Instance Methods
extension Note {
    
    // Save
    func save(from givenCtx: NSManagedObjectContext? = nil) {
        return(Note.save(from: givenCtx))
    }
    
    // Delete
    func delete(from givenCtx: NSManagedObjectContext? = nil, commit: Bool? = false) {
        return(Note.delete(from: givenCtx, object: self, commit: commit))
    }
}

// MARK: - Proxies
extension Note {
    var proxyForComparison: String {
        guard let title = self.title else {
            return("")
        }
        return(title.uppercased())
    }
}

// MARK: - Comparable
extension Note: Comparable {
    public static func <(lhs: Note, rhs: Note) -> Bool {
        return(lhs.proxyForComparison < rhs.proxyForComparison)
    }
}
