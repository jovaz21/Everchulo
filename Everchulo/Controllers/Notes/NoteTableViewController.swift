//
//  NoteTableViewController.swift
//  Everchulo
//
//  Created by ATEmobile on 20/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit
import CoreData

// NoteTableViewControllerDelegate: class {
protocol NoteTableViewControllerDelegate: AnyObject {
    func noteTableViewController(_ vc: NoteTableViewController, didSelectNote note: Note)
}

// MARK: - Controller Stuff
class NoteTableViewController: UITableViewController {
    static let NOTEDIDCHANGE_NOTIFICATION = Notification.Name("NoteDidChangeNotification")
    static let NOTE_KEY                   = "NoteKey"
    
    // MARK: - Properties
    var viewMode: ViewMode = .SingleView
    var fetchedNotebooksController: NSFetchedResultsController<Notebook>!
    var fetchedNotesController: NSFetchedResultsController<Note>!
    
    // Last Selected Note/Row+Section
    var lastSelectedNote: Note { return(fetchedNotebooksController.object(at: IndexPath(row: lastSelectedSection, section: 0)).sortedNotes[lastSelectedRow]) }
    var lastSelectedRow: Int {
        get {
            return(UserDefaults.standard.integer(forKey: "NoteTableView.LastSelectedRow"))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "NoteTableView.LastSelectedRow")
            UserDefaults.standard.synchronize()
        }
    }
    var lastSelectedSection: Int {
        get {
            return(UserDefaults.standard.integer(forKey: "NoteTableView.LastSelectedSection"))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "NoteTableView.LastSelectedSection")
            UserDefaults.standard.synchronize()
        }
    }
    
    // Delegate
    weak var delegate: NoteTableViewControllerDelegate?
    
    // Note Controller
    var noteController: NoteController?
    
    // MARK: - Init
    init() { super.init(style: UITableViewStyle.plain)
        
        /* set */
        self.title = i18NString("NoteTableViewController.title")
        self.editButtonItem.title = i18NString("com.apple.UIKit.Edit")
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // View Is Loaded:
    // Setup UIView Layer
    override func viewDidLoad() { super.viewDidLoad()
        
        /* register */
        tableView.register(UINib.init(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: "NoteTableViewCell")
        
        /* set */
        self.noteController = NoteController(vc: self)
        
        /* setup */
        self.setupUIView()
    }
    
    // View Will Appear:
    // Always Set LastSelected Note as Selected
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated)
        
        /* check */
        if (self.viewMode == .SingleView) {
            return
        }
        
        /* select */
        tableView.selectRow(at: IndexPath(row: self.lastSelectedRow, section: self.lastSelectedSection), animated: false, scrollPosition: .none)
    }
    
    // View Will Disappear:
    // Resets UISplitVC's Display Mode to .Automatic
    override func viewWillDisappear(_ animated: Bool) { super.viewWillAppear(animated)
        self.splitViewController?.preferredDisplayMode = .automatic
    }
    
    // MARK: - On Row Selected:
    //  - Invoke Delegate
    //  - Notify Observers
    //  - Remember Row as Last Selected
    func onRowSelected(at indexPath: IndexPath) {
        let note = self.getNote(section: indexPath.section, row: indexPath.row)!
        
        /* delegate */
        if (delegate != nil) { // Delegate
            delegate!.noteTableViewController(self, didSelectNote: note)
        }
        
        /* notify */
        let notification = Notification(name: NoteTableViewController.NOTEDIDCHANGE_NOTIFICATION, object: self, userInfo: [NoteTableViewController.NOTE_KEY: note])
        NotificationCenter.default.post(notification)
        
        /* set */
        self.lastSelectedSection    = indexPath.section
        self.lastSelectedRow        = indexPath.row
    }
    
    // MARK: - On New Note:
    // - If no Notebook is given, retrieve Active one
    // - If no Active Notebook is retrieved, create a default one
    // - Add an empty Note to the Notebook
    // - Present NoteDetailViewController to the user...
    func onNewNote(_ notebook: Notebook? = nil) {
        let noteDetailVC = NoteDetailViewController(notebook: notebook)
        noteDetailVC.delegate = self
        self.present(noteDetailVC.wrappedInNavigation(), animated: true)
    }
    
    // Height Constants
    let SECTIONHEADER_HEIGHT    = CGFloat(60)
    let ROW_HEIGHT              = UITableViewAutomaticDimension
    
    // Action Buttons
    var newNoteButtonItem: UIBarButtonItem!
    var menuBarButtonItem: UIBarButtonItem!
}

// MARK: - View Stuff
extension NoteTableViewController {
    
    // View Mode
    enum ViewMode: String {
        case MasterDetail
        case SingleView
    }
    
    // Setup UIView:
    //  - Creates a UIBarButtonItem so that Users can ...
    func setupUIView() {
        
        /* init */
        tableView.estimatedRowHeight = ROW_HEIGHT
        tableView.rowHeight = ROW_HEIGHT
        tableView.sectionHeaderHeight = SECTIONHEADER_HEIGHT
        
        /* NAVIGATIONBAR */
        self.editButtonItem.title = i18NString("com.apple.UIKit.Edit")
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor = Styles.activeColor
        //self.navigationItem.rightBarButtonItems = [self.editButtonItem]
        
        /* TOOLBAR */
        navigationController?.toolbar.isHidden  = false
        navigationController?.isToolbarHidden   = false
        self.menuBarButtonItem = UIBarButtonItem(image: UIImage(named: "dots-horizontal")!, style: .done, target: self, action: #selector(displayNoteMenuAction))
        self.menuBarButtonItem.tintColor = Styles.activeColor
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.newNoteButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(newNoteAction))
        self.newNoteButtonItem.tintColor = Styles.activeColor
        self.setToolbarItems([menuBarButtonItem, flexibleSpace, newNoteButtonItem], animated: false)

        /* Setup Data */
        self.setupData()
    }
    @objc func newNoteAction() { DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
        self.onNewNote()
    })}
    @objc func displayNoteMenuAction() { DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
        let trashedNotesCount = Note.listTrashed().count
        
        /* menu */
        let actionSheetMenu = makeActionSheetMenu(title: nil, message: nil, items:
            (
                title:      i18NString("NoteTableViewController.notebookSettingsMsg"),
                style:      .default,
                image:      UIImage(named: "notebook"),
                hidden:     (self.fetchedNotesController.sections!.count != 1),
                handler:    { (alertAction) in
                    let notebook = self.getNotebook(section: 0)!
                    let notebookDetailVC = NotebookDetailViewController(notebook: notebook, isModal: true)
                    self.present(notebookDetailVC.wrappedInNavigation(), animated: true, completion: nil)
                }
            ),
            (
                title:      i18NString("NoteTableViewController.notebooksSettingsMsg"),
                style:      .default,
                image:      UIImage(named: "notebook"),
                hidden:     (self.fetchedNotesController.sections!.count <= 1),
                handler:    { (alertAction) in
                    let notebook = self.getNotebook(section: 0)!
                    let notebookTableVC = NotebookTableViewController(notebook: notebook)
                    self.present(notebookTableVC.wrappedInNavigation(), animated: true, completion: nil)
                }
            ),
            (
                title:      "\(i18NString("NoteTableViewController.trashMsg")) (\(trashedNotesCount))",
                style:      .default,
                image:      UIImage(named: "trash_img"),
                hidden:     (trashedNotesCount <= 0),
                handler:    { (alertAction) in
                    let noteTrashVC = NoteTrashViewController()
                    self.present(noteTrashVC.wrappedInNavigation(), animated: true, completion: nil)
                }
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
        self.present(actionSheetMenu, animated: true, completion: nil)
    })}
    
    // MARK: - Instance Methods
    func setViewMode(_ value: ViewMode) {
        
        /* set */
        self.viewMode = value
        
        /* done */
        return
    }
}

// ImagesCollectionCell Delegate
extension NoteTableViewController: ImagesCollectionCellDelegate {
    
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
