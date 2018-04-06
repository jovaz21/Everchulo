//
//  NotebookController.swift
//  Everchulo
//
//  Created by ATEmobile on 6/4/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

// MARK: - Controller Stuff
class NotebookController {
    let vc: UIViewController
    var notebook: Notebook? = nil
    var isModal: Bool = false
    
    // MARK: - Init
    init(vc: UIViewController) { self.vc = vc }
    
    // Delete Notebook
    func deleteNotebook(notebook: Notebook, isModal: Bool) {
        
        /* set */
        self.notebook = notebook
        self.isModal = isModal
        
        /* confirm */
        let confirmDialog = makeConfirmDialog(title: "\(i18NString("NotebookDetailViewController.confirmMsg")) '\(self.notebook!.name!)'?", message: "", okAction: (
            title:      i18NString("es.atenet.app.Delete"),
            style:      .destructive,
            handler:    { (action) in DispatchQueue.main.async { self.doDeleteNotebook() }
        }), cancelAction: (
            title:      i18NString("es.atenet.app.Cancel"),
            style:      nil,
            handler:    { (action) in DispatchQueue.main.async { }
        })
        )
        
        /* present */
        vc.present(confirmDialog, animated: true, completion: nil)
    }
    func doDeleteNotebook() {
        
        /* confirm */
        let actionSheetMenu = makeActionSheetMenu(title: nil, message: nil, items:
            (
                title:      i18NString("NotebookDetailViewController.moveMsg"),
                style:      .default,
                image:      nil,
                hidden:     false,
                handler:    { (action) in DispatchQueue.main.async { self.doMoveNotes() }}
            ),
            (
                title:      i18NString("es.atenet.app.DeleteAll"),
                style:      .destructive,
                image:      nil,
                hidden:     false,
                handler:    { (action) in DispatchQueue.main.async {
                                                        
                    /* delete */
                    if (self.notebook!.isActive()) {
                        var notebooks = Notebook.listAll().filter() {
                        return($0.activeNotes.count > 0)
                    }
                    notebooks.remove(at: notebooks.index(of: self.notebook!)!)
                        if (notebooks.count > 0) {
                            notebooks[0].setActive()
                        }
                    }
                    self.notebook!.delete(commit: true)
                                                        
                    /* check */
                    if (self.isModal) {
                        self.vc.presentingViewController?.dismiss(animated: true)
                    } else {
                        self.vc.navigationController?.popViewController(animated: true)
                    }
                 }}
            ),
            (
                 title:      i18NString("es.atenet.app.Cancel"),
                 style:      .cancel,
                 image:      nil,
                 hidden:     false,
                 handler:    nil
            )
        )
        
        /* present */
        self.vc.present(actionSheetMenu, animated: true, completion: nil)
    }
    func doMoveNotes() {
        
        /* set */
        let notebookSelectorVC = NotebookSelectorTableViewController(notebook: self.notebook!)
        notebookSelectorVC.setViewMode(.moveAll)
        notebookSelectorVC.delegate = self
        
        /* show */
        self.vc.present(notebookSelectorVC.wrappedInNavigation(), animated: true)
    }
}

// NotebookSelectorTableViewController Delegate
extension NotebookController: NotebookSelectorTableViewControllerDelegate {
    func notebookSelectorTableViewController(_ vc: NotebookSelectorTableViewController, didCancel notebook: Notebook, presentingViewController: UIViewController) {
    }
    func notebookSelectorTableViewController(_ vc: NotebookSelectorTableViewController, didSelectNotebook notebook: Notebook) {
        print("didSelectNotebook: ", notebook)
        
        /* move */
        if (self.notebook!.isActive()) {
            notebook.setActive()
        }
        self.notebook!.activeNotes.forEach() {
            $0.moveToNotebook(notebook)
        }
        
        /* delete */
        self.notebook!.delete(commit: true)
        
        /* check */
        if (self.isModal) {
            self.vc.presentingViewController?.dismiss(animated: true)
        } else {
            self.vc.navigationController?.popViewController(animated: true)
        }
    }
}
