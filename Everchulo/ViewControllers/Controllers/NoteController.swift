//
//  NoteController.swift
//  Everchulo
//
//  Created by ATEmobile on 8/4/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

// MARK: - Controller Stuff
class NoteController {
    let vc: UIViewController
    
    // MARK: - Init
    init(vc: UIViewController) { self.vc = vc }
    
    // Duplicate
    func duplicate(fromNote: Note) -> Note {
        
        /* create */
        let note = Note.create(fromNote.notebook!, title: "\(i18NString("NoteController.copyOfMsgLabel")) \(fromNote.title!)", content: fromNote.content, tags: fromNote.tags)!
        note.setActive()
        
        /* done */
        return(note)
    }
    
    // Move to Trash
    func moveToTrash(note: Note) {
        var notebooks = Notebook.listAll().filter() {
            return($0.activeNotes.count > 0)
        }
        let notebook    = note.notebook!
        var notes       = notebook.activeNotes
        
        /* trash */
        note.moveToTrash()
        notes.remove(at: notes.index(of: note)!)
        
        /* check */
        if (notes.count <= 0) {
            notebooks.remove(at: notebooks.index(of: notebook)!)
            if (notebook.isActive() && (notebooks.count > 0)) {
                notebooks[0].setActive()
            }
            notebook.delete()
        }
        
        /* commit */
        DataManager.save()
    }
}
