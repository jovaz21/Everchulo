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
        notebook!.add(notes: [note1, note2, note3, note4, note5, note6])
        let sortedNotes = notebook!.sortedNotes
        XCTAssertNotNil(sortedNotes)
        
        // Order
        let firstNote:  Note = sortedNotes.first!
        let lastNote:   Note = sortedNotes.last!
        XCTAssertEqual(firstNote.title, "A")
        XCTAssertEqual(lastNote.title, "F")
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
}
