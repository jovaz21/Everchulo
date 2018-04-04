//
//  Notebook+Extensions.swift
//  Everchulo
//
//  Created by ATEmobile on 18/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import Foundation
import CoreData

// MARK: - CRUD Helpers
extension Notebook {
    
    // Status
    enum Status: String {
        case IDLE
        case ACTIVE
    }
    
    // Returns Fetch Request for All Results
    static func fetchRequestForAllResults(from givenCtx: NSManagedObjectContext? = nil) -> (ctx: NSManagedObjectContext, fetchRequest: NSFetchRequest<Notebook>) {
        let ctx: NSManagedObjectContext = givenCtx ?? DataManager.shared.viewContext
        
        /* set */
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        
        /* done */
        return((ctx, fetchRequest))
    }
    
    // List All
    static func listAll(from givenCtx: NSManagedObjectContext? = nil, returnsObjectsAsFaults: Bool? = true) -> [Notebook] {
        let (ctx, fetchRequest) = Notebook.fetchRequestForAllResults(from: givenCtx)

        /* set */
        fetchRequest.returnsObjectsAsFaults = returnsObjectsAsFaults!
        
        /* fetch */
        let res = try? ctx.fetch(fetchRequest)
        return(res ?? [Notebook]())
    }
    
    // FindById
    static func findById(from givenCtx: NSManagedObjectContext? = nil, objectID oid: NSManagedObjectID) -> Notebook? {
        let ctx: NSManagedObjectContext = givenCtx ?? DataManager.shared.viewContext
        return(ctx.object(with: oid) as? Notebook)
    }
    
    // FindBy Name
    static func findByName(from givenCtx: NSManagedObjectContext? = nil, name: String) -> Notebook? {
        let ctx: NSManagedObjectContext = givenCtx ?? DataManager.shared.viewContext

        /* set */
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        /* fetch */
        guard let resArray = try? ctx.fetch(fetchRequest) else { return(nil) }
        return(resArray.first)
    }
    
    // Get Active
    static func getActive(from givenCtx: NSManagedObjectContext? = nil) -> Notebook? {
        let ctx: NSManagedObjectContext = givenCtx ?? DataManager.shared.viewContext
        
        /* set */
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "status == %@", Status.ACTIVE.rawValue)
        
        /* fetch */
        guard let resArray = try? ctx.fetch(fetchRequest) else { return(nil) }
        return(resArray.first)
    }
    
    // Create
    static func create(into givenCtx: NSManagedObjectContext? = nil, name: String, commit: Bool? = false) -> Notebook? {
        let ctx: NSManagedObjectContext = givenCtx ?? DataManager.shared.viewContext
        
        /* check */
        if let obj = Notebook.findByName(from: ctx, name: name) {
            return(obj)
        }
        
        /* insert */
        guard let nsObj = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into: ctx) as? Notebook else { return(nil) }
        
        /* set */
        nsObj.name      = name
        nsObj.status    = Status.IDLE.rawValue
        
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
        Notebook.listAll(from: ctx).forEach({(obj: Notebook) in
            obj.delete(from: ctx)
        })
        
        /* check */
        if (commit!) {
            DataManager.save()
        }
    }
}

// MARK: - Instance Methods
extension Notebook {
    
    // Save
    func save(from givenCtx: NSManagedObjectContext? = nil) {
        return(DataManager.save(from: givenCtx))
    }
    
    // Delete
    func delete(from givenCtx: NSManagedObjectContext? = nil, commit: Bool? = false) {
        return(DataManager.delete(from: givenCtx, object: self, commit: commit))
    }
    
    // Set Name
    func setName(with givenCtx: NSManagedObjectContext? = nil, _ name: String, commit: Bool? = false) {
        
        /* set */
        self.name = name
        self.notes?.forEach() {(o: Any) in
            let note = o as! Note
            note.notebookDidUpdate()
        }
        
        /* */
        if (commit!) {
            self.save(from: givenCtx)
        }
    }
    
    // Set Active
    func setActive(with givenCtx: NSManagedObjectContext? = nil, commit: Bool? = false) {
        
        /* reset */
        Notebook.listAll(from: givenCtx).forEach() {
            $0.status = Status.IDLE.rawValue
            $0.notes?.forEach() {(o: Any) in
                let note = o as! Note
                note.notebookDidUpdate()
            }
        }
        
        /* set */
        self.status = Status.ACTIVE.rawValue
        self.notes?.forEach() {(o: Any) in
            let note = o as! Note
            note.notebookDidUpdate()
        }
        
        /* */
        if (commit!) {
            self.save(from: givenCtx)
        }
    }
    
    // Is Active
    func isActive() -> Bool { return(self.status == Status.ACTIVE.rawValue) }
}

// MARK: - Notes Stuff
extension Notebook {
    var count: Int { return(self.notes!.count) }
    var activeNotes: [Note] {
        guard let noteArray = self.notes?.allObjects as? [Note] else { return([Note]()) }
        return(noteArray.filter() { $0.status! == Note.Status.ACTIVE.rawValue })
    }
    var sortedNotes: [Note] {
        return(activeNotes.sorted(){ return($0 < $1) })
    }
    
    // Add Note
    func add(note: Note) -> Note {
        note.notebook = self
        return(note)
    }
    
    // Add Notes
    func add(notes: [Note]) -> [Note] { notes.forEach { _ = add(note: $0) }; return(notes) }
}

// MARK: - Proxies
extension Notebook {
    var proxyForComparison: String {
        guard let name = self.name else {
            return("")
        }
        return(name.uppercased())
    }
}

// MARK: - Comparable
extension Notebook: Comparable {
    public static func <(lhs: Notebook, rhs: Notebook) -> Bool {
        return(lhs.proxyForComparison < rhs.proxyForComparison)
    }
}
