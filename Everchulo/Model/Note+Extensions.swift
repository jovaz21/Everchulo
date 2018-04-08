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
    
    // Status
    enum Status: String {
        case IDLE
        case ACTIVE
        case TIMEDOUT
        case TRASHED
    }
    
    // Notebook Name
    var notebookName: String {
        if (self.notebook == nil) {
            return("")
        }
        return(self.notebook!.name!)
    }
    override public func setValue(_ value: Any?, forUndefinedKey key: String) {
        super.setValue(value, forKey: key)
    }
    override public func value(forUndefinedKey key: String) -> Any? {
        if (key == "notebookName") {
            return(self.notebookName)
        }
        return(super.value(forUndefinedKey: key))
    }
    
    // Returns Fetch Request for Results with Status
    static func fetchRequestForResultsWithStatus(_ status: Status, from givenCtx: NSManagedObjectContext? = nil) -> (ctx: NSManagedObjectContext, fetchRequest: NSFetchRequest<Note>) {
        let ctx: NSManagedObjectContext = givenCtx ?? DataManager.shared.viewContext
        
        /* set */
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "status == %@", status.rawValue)
        ])
        
        /* done */
        return((ctx, fetchRequest))
    }
    
    // Returns Fetch Request for All Results
    static func fetchRequestForAllResults(from givenCtx: NSManagedObjectContext? = nil) -> (ctx: NSManagedObjectContext, fetchRequest: NSFetchRequest<Note>) {
        let ctx: NSManagedObjectContext = givenCtx ?? DataManager.shared.viewContext
        
        /* set */
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "status == %@", Status.ACTIVE.rawValue)
        ])
        
        /* done */
        return((ctx, fetchRequest))
    }
    
    // List All
    static func listAll(from givenCtx: NSManagedObjectContext? = nil, returnsObjectsAsFaults: Bool? = true) -> [Note] {
        let (ctx, fetchRequest) = Note.fetchRequestForAllResults(from: givenCtx)
        
        /* set */
        fetchRequest.returnsObjectsAsFaults = returnsObjectsAsFaults!
        
        /* fetch */
        let res = try? ctx.fetch(fetchRequest)
        return(res ?? [Note]())
    }
    
    // List Trashed
    static func listTrashed(from givenCtx: NSManagedObjectContext? = nil, returnsObjectsAsFaults: Bool? = true) -> [Note] {
        let (ctx, fetchRequest) = Note.fetchRequestForResultsWithStatus(Status.TRASHED, from: givenCtx)
        
        /* set */
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
    static func create(into givenCtx: NSManagedObjectContext? = nil, _ notebook: Notebook, title givenTitle: String? = nil, content: String? = nil, tags: String? = nil, commit: Bool? = false) -> Note? {
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
        nsObj.moveToNotebook(notebook)
        
        /* set */
        nsObj.content    = content
        nsObj.tags       = tags
        
        /* set */
        nsObj.status = Status.IDLE.rawValue
        
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
    
    // Delete All
    static func deleteAll(from givenCtx: NSManagedObjectContext? = nil, commit: Bool? = false) {
        let ctx: NSManagedObjectContext = givenCtx ?? DataManager.shared.viewContext
        
        /* delete */
        Note.listAll(from: ctx).forEach({(obj: Note) in
            obj.delete(from: ctx)
        })
        
        /* check */
        if (commit!) {
            DataManager.save()
        }
    }
}

// MARK: - Instance Methods
extension Note {
    
    // Save
    func save(from givenCtx: NSManagedObjectContext? = nil) {
        return(DataManager.save(from: givenCtx))
    }
    
    // Delete
    func delete(from givenCtx: NSManagedObjectContext? = nil, commit: Bool? = false) {
        return(DataManager.delete(from: givenCtx, object: self, commit: commit))
    }
    
    // Set Notebook
    func moveToNotebook(with givenCtx: NSManagedObjectContext? = nil, _ notebook: Notebook, commit: Bool? = false) {
        
        /* set */
        self.notebook = notebook
        self.notebookDidUpdate()
        
        /* */
        if (commit!) {
            self.save(from: givenCtx)
        }
    }
    func notebookDidUpdate() {
        self.notebookSortCriteria = "\(notebook!.status!)-\(notebook!.name!)"
    }
    
    // Set Active
    func setActive(with givenCtx: NSManagedObjectContext? = nil, commit: Bool? = false) {
        
        /* set */
        self.status = Status.ACTIVE.rawValue
        if (commit!) {
            self.save(from: givenCtx)
        }
    }
    
    // Is Active
    func isActive() -> Bool { return(self.status == Status.ACTIVE.rawValue) }
    
    // Move to Trash
    func moveToTrash(with givenCtx: NSManagedObjectContext? = nil, commit: Bool? = false) {
        self.status = Status.TRASHED.rawValue
        if (commit!) {
            self.save(from: givenCtx)
        }
    }
    
    // Is Trashed
    func isTrashed() -> Bool { return(self.status == Status.TRASHED.rawValue) }
    
    // Set Alarm
    func setAlarm(_ date: Date) {
        self.alarmTimestamp = date.timeIntervalSince1970
    }
    
    // Reset Alarm
    func resetAlarm() {
        self.alarmTimestamp = 0
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
        if (lhs.notebook?.objectID == rhs.notebook?.objectID) {
            return(lhs.proxyForComparison < rhs.proxyForComparison)
        }
        if ((lhs.notebook != nil) && (rhs.notebook == nil)) {
            return(true)
        }
        if ((lhs.notebook == nil) && (rhs.notebook != nil)) {
            return(false)
        }
        if (lhs.notebook!.status == Notebook.Status.ACTIVE.rawValue) {
            return(true)
        }
        if (rhs.notebook!.status == Notebook.Status.ACTIVE.rawValue) {
            return(false)
        }
        return(lhs.notebook! < rhs.notebook!)
    }
}
