//
//  NoteTrashViewController.swift
//  Everchulo
//
//  Created by ATEmobile on 1/4/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Controller Stuff
class NoteTrashViewController: UITableViewController {
    
    // MARK: - Properties
    var fetchedNotesController: NSFetchedResultsController<Note>!
    
    // MARK: - Init
    init() { super.init(style: UITableViewStyle.plain)
        
        /* set */
        self.title = i18NString("NoteTrashViewController.title")
        self.editButtonItem.title = i18NString("com.apple.UIKit.Edit")
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // View Is Loaded:
    // Setup UIView Layer
    override func viewDidLoad() { super.viewDidLoad()
        
        /* register */
        tableView.register(UINib.init(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: "NoteTableViewCell")
        
        /* setup */
        self.setupUIView()
    }
    
    // On Row Selected:
    //  - Confirm Dialog
    //  - Recover if Desired
    func onRowSelected(at indexPath: IndexPath) {
        let note = self.fetchedNotesController.fetchedObjects![indexPath.row]
        
        // Declare Alert message
        let dialogMessage = UIAlertController(title: "\(i18NString("NoteTrashViewController.confirmRecoverMsg")) '\(note.notebook!.name!)'?", message: "", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: i18NString("NoteTrashViewController.recoverMsg"), style: .default, handler: { (action) -> Void in
            DispatchQueue.main.async {
                note.setActive(commit: true)
            }
        })
        ok.setValue(Styles.activeColor, forKey: "titleTextColor")
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: i18NString("es.atenet.app.Cancel"), style: .cancel)
        cancel.setValue(Styles.activeColor, forKey: "titleTextColor")
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    // Height Constants
    let SECTIONHEADER_HEIGHT    = CGFloat(60)
    let ROW_HEIGHT              = UITableViewAutomaticDimension
    
    // Action Buttons
    var cancelButtonItem: UIBarButtonItem!
}

// MARK: - View Stuff
extension NoteTrashViewController {
    
    // Setup UIView
    func setupUIView() {
        
        /* init */
        tableView.estimatedRowHeight = ROW_HEIGHT
        tableView.rowHeight = ROW_HEIGHT
        tableView.sectionHeaderHeight = SECTIONHEADER_HEIGHT
        
        /* NAVIGATIONBAR */
        self.cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancelAction))
        self.navigationItem.leftBarButtonItem = self.cancelButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor = Styles.activeColor
        
        /* fetch */
        self.fetchTrashedNotes()
    }
    @objc func cancelAction() {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    // MARK: - Instance Methods
    
    // Fetch Trashed Notes
    func fetchTrashedNotes() {
        let (ctx, fetchRequest) = Note.fetchRequestForResultsWithStatus(Note.Status.TRASHED)
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        fetchRequest.sortDescriptors = [sortByTitle]
        self.fetchedNotesController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedNotesController.delegate = self
        try! self.fetchedNotesController.performFetch()
    }
    
    // MARK: - Table View DISPLAY Delegate Functions
    
    /* SECTIONS */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return(1)
    }
    
    /* ROWS */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(fetchedNotesController.sections![section].numberOfObjects)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cellId  = "NoteTableViewCell"
        //let cell    = tableView.dequeueReusableCell(withIdentifier: cellId) as? NoteTableViewCell
        //            ?? NoteTableViewCell.newLoadedCell
        let cell = NoteTableViewCell.newLoadedCell
        
        /* set */
        let note = self.fetchedNotesController.fetchedObjects![indexPath.row]
        
        /* set */
        cell.titleLabel.text    = note.title
        cell.dateLabel.text     = "23 mar'18"
        cell.contentLabel.text  = note.content
        
        /* set */
        cell.setImages(images: [UIImage]())
        cell.cellDelegate = self
        
        /* donde */
        return(cell)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return(UITableViewAutomaticDimension)
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return(UITableViewAutomaticDimension)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: IndexPath(row: indexPath.row, section: 0), animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
            self.onRowSelected(at: indexPath)
        })
    }
    
    // Table View EDIT Delegate Functions
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? { return(i18NString("es.atenet.app.Delete")) }
    override func setEditing(_ editing: Bool, animated: Bool) { super.setEditing(editing, animated: animated)
        
        /* check */
        if (self.isEditing) {
            self.editButtonItem.title = i18NString("com.apple.UIKit.Done")
        }
        else {
            self.editButtonItem.title = i18NString("com.apple.UIKit.Edit")
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return(true) }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note = self.fetchedNotesController.fetchedObjects![indexPath.row]
            
            // Declare Alert message
            let dialogMessage = UIAlertController(title: "\(i18NString("NoteTrashViewController.confirmDeleteMsg"))", message: "", preferredStyle: .alert)
            
            // Create OK button with action handler
            let ok = UIAlertAction(title: i18NString("NoteTrashViewController.deleteMsg"), style: .destructive, handler: { (action) -> Void in
                DispatchQueue.main.async {
                    note.delete(commit: true)
                }
            })
            
            // Create Cancel button with action handlder
            let cancel = UIAlertAction(title: i18NString("es.atenet.app.Cancel"), style: .cancel)
            cancel.setValue(Styles.activeColor, forKey: "titleTextColor")
            
            //Add OK and Cancel button to dialog message
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            
            // Present dialog message to user
            self.present(dialogMessage, animated: true, completion: nil)
        }
    }
}

// MARK: NSFetchedResultsController Delegate
extension NoteTrashViewController: NSFetchedResultsControllerDelegate {
    
    // Begin Updates on UITableView
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    // Rows Inserted|Deleted|Updated|Moved
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            let atIndexPath = controller.indexPath(forObject: anObject as! NSFetchRequestResult)!
            self.tableView.insertRows(at: [atIndexPath], with: .none)
            break
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update, .move:
            if (newIndexPath != indexPath) {
                self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
            }
            break
        }
    }
    
    // End Updates on UITableView
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        self.tableView.reloadData()
    }
}

// ImagesCollectionCell Delegate
extension NoteTrashViewController: ImagesCollectionCellDelegate {
    
    // Image Cell Tapped
    func collectionView(imageCell: ImagesCollectionViewCell?, didTappedInTableView tableCell: NoteTableViewCell) {
        
        /* set */
        let imageDetailVC = ImageDetailViewController(image: imageCell!.imageView.image!)
        self.present(imageDetailVC, animated: true) {
            imageDetailVC.closeButton.addTarget(self, action: #selector(self.dismissImageDetailVC), for: .touchUpInside)
        }
    }
    @objc func dismissImageDetailVC() { DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
        self.dismiss(animated: true)
    })}
}
