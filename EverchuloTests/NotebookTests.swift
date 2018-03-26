//
//  NotebookTests.swift
//  EverchuloTests
//
//  Created by ATEmobile on 19/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import XCTest
import CoreData
@testable import Everchulo

class NotebookTests: XCTestCase {
    
    // Init / Halt Tests
    override func setUp() { super.setUp()
        DataManager.setenv(value: DataManagerEnvironment.testing)
        Notebook.deleteAll()
    }
    override func tearDown() { super.tearDown()
    }
    
    // Notebook
    func testNotebookLifecycle() {
        
        // Init
        let notebook = Notebook.create(name: "Libreta para crear y para borrar")
        XCTAssertNotNil(notebook)
        
        // Halt
        notebook!.delete()
        XCTAssertNil(Notebook.findByName(name: "Libreta para crear y para borrar"))
    }
    func testNotebookEquality() {
        let notebook = Notebook.create(name: "Libreta para comparar")
        XCTAssertNotNil(notebook)
        
        // Identity
        XCTAssertEqual(notebook, notebook)
        
        // Equality
        XCTAssertEqual(notebook, Notebook.create(name: "Libreta para comparar"))
        
        // Unequality
        XCTAssertNotEqual(notebook, Notebook.create(name: "Libreta diferente"))
    }
    func testNoteBookIsAlphabeticallyOrdered() {
        XCTAssertLessThan(Notebook.create(name: "Abcdef")!, Notebook.create(name: "Ghijkl")!)
    }
    func testNotebookSortedNotes() {
        let notebook = Notebook.create(name: "Primera libreta")

        /* init */
        let note1   = Note.create(title: "F", content: "Note1")!
        let note2   = Note.create(title: "C", content: "Note2")!
        let note3   = Note.create(title: "B", content: "Note3")!
        let note4   = Note.create(title: "E", content: "Note4")!
        let note5   = Note.create(title: "A", content: "Note5")!
        let note6   = Note.create(title: "D", content: "Note6")!
        
        // Init
        _ = notebook!.add(notes: [note1, note2, note3, note4, note5, note6])
        let sortedNotes = notebook!.sortedNotes
        XCTAssertNotNil(sortedNotes)
        
        // Order
        let firstNote:  Note = sortedNotes.first!
        let lastNote:   Note = sortedNotes.last!
        XCTAssertEqual(firstNote.title, "A")
        XCTAssertEqual(lastNote.title, "F")
    }
    func testNotebookWithActiveStatusAlwaysFirst() {
        
        /* */
        Notebook.deleteAll()
        
        /* init */
        let notebook1 = Notebook.create(name: "Notebook1")
        let notebook2 = Notebook.create(name: "Notebook2")
        let notebook3 = Notebook.create(name: "Notebook3")
        
        let note1   = Note.create(title: "F", content: "Note1")!
        let note2   = Note.create(title: "C", content: "Note2")!
        let note3   = Note.create(title: "B", content: "Note3")!
        let note4   = Note.create(title: "E", content: "Note4")!
        let note5   = Note.create(title: "A", content: "Note5")!
        let note6   = Note.create(title: "D", content: "Note6")!
        
        // Init
        _ = notebook1!.add(notes: [note1, note2, note3])
        let sortedNotes1 = notebook1!.sortedNotes
        XCTAssertNotNil(sortedNotes1)
        
        _ = notebook2!.add(notes: [note4, note5])
        let sortedNotes2 = notebook2!.sortedNotes
        XCTAssertNotNil(sortedNotes2)
        
        _ = notebook3!.add(notes: [note6])
        let sortedNotes3 = notebook3!.sortedNotes
        XCTAssertNotNil(sortedNotes3)
        
        // Order
        let firstNote1:  Note = sortedNotes1.first!
        let lastNote1:   Note = sortedNotes1.last!
        XCTAssertEqual(firstNote1.title, "B")
        XCTAssertEqual(lastNote1.title, "F")
        
        let firstNote2:  Note = sortedNotes2.first!
        let lastNote2:   Note = sortedNotes2.last!
        XCTAssertEqual(firstNote2.title, "A")
        XCTAssertEqual(lastNote2.title, "E")
        
        XCTAssertEqual(sortedNotes3.first!, sortedNotes3.last!)
        
        // Active Notebook Always First
        notebook1?.setActive()
        var sortedNotes = Note.listAll(returnsObjectsAsFaults: false).sorted(){ return($0 < $1) }
        print("NOTEBOOK1 ACTIVE: ")
        sortedNotes.forEach({ (note: Note) in
            print(note.notebook?.name ?? "", note.title ?? "", note.content ?? "")
        })
        var firstNote = sortedNotes.first!
        var lastNote = sortedNotes.last!
        XCTAssertEqual(firstNote, note3)
        XCTAssertEqual(lastNote, note6)
        print("-----------------")
        
        notebook2?.setActive()
        sortedNotes = Note.listAll(returnsObjectsAsFaults: false).sorted(){ return($0 < $1) }
        print("NOTEBOOK2 ACTIVE: ")
        sortedNotes.forEach({ (note: Note) in
            print(note.notebook?.name ?? "", note.title ?? "", note.content ?? "")
        })
        firstNote = sortedNotes.first!
        lastNote = sortedNotes.last!
        XCTAssertEqual(firstNote, note5)
        XCTAssertEqual(lastNote, note6)
        print("-----------------")
        
        notebook3?.setActive()
        sortedNotes = Note.listAll(returnsObjectsAsFaults: false).sorted(){ return($0 < $1) }
        print("NOTEBOOK3 ACTIVE: ")
        sortedNotes.forEach({ (note: Note) in
            print(note.notebook?.name ?? "", note.title ?? "", note.content ?? "")
        })
        firstNote = sortedNotes.first!
        lastNote = sortedNotes.last!
        XCTAssertEqual(firstNote, note6)
        XCTAssertEqual(lastNote, note4)
        print("-----------------")
    }
    
    // Note
    func testNoteLifecycle() {
        
        // Init
        let note = Note.create(title: "Mi Título de Nota", content: "Mi nota...")
        XCTAssertNotNil(note)
        
        // Halt
        let objectID = note!.objectID; note!.delete()
        XCTAssertNil(Notebook.findById(objectID: objectID))
    }
    func testNoteEquality() {
        let note = Note.create(title: "Nota para Comparar", content: "Mi nota...")
        XCTAssertNotNil(note)
        
        // Identity
        XCTAssertEqual(note, note)
        
        // Equality
        XCTAssertEqual(note, Note.findById(objectID: note!.objectID))
        
        // Unequality
        XCTAssertNotEqual(note, Note.findByText(text: "xxx"))
    }
    func testNoteIsAlphabeticallyOrdered() {
        XCTAssertLessThan(Note.create(content: "Abcdef")!, Note.create(content: "Ghijkl")!)
    }
    func testNoteStatus() {
        let allActiveNotesCount = Note.listAll().count
        let trashedNotesCount   = Note.listTrashed().count
        
        /* init */
        let note = Note.create(title: "Nota1", content: "Contenido Nota 1")!
        let _ = Note.create(title: "Nota2", content: "Contenido Nota 2")
        
        // Active
        XCTAssertEqual(Note.listAll().count, allActiveNotesCount+2)
        
        // Trashed
        note.moveToTrash()
        XCTAssertEqual(Note.listAll().count, allActiveNotesCount+1)
        XCTAssertEqual(Note.listTrashed().count, trashedNotesCount+1)
    }
}
