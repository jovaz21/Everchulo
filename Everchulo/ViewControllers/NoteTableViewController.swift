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
    var fetchedResultsController: NSFetchedResultsController<Note>!
    
    // Last Selected Note/Row+Section
    var lastSelectedNote: Note { return(fetchedResultsController.object(at: IndexPath(row: lastSelectedRow, section: lastSelectedSection))) }
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
    
    // MARK: - Init
    init() {
        super.init(style: UITableViewStyle.plain)
        title = "Notas"
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // View Is Loaded:
    // Setup UIView Layer
    override func viewDidLoad() { super.viewDidLoad()
        self.setupUIView()
    }
    
    // View Will Appear:
    // Always Set LastSelected Note as Selected
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated)
        tableView.selectRow(at: IndexPath(row: self.lastSelectedRow, section: self.lastSelectedSection), animated: false, scrollPosition: .none)
    }
    
    // View Will Disappear:
    // Resets UISplitVC's Display Mode to .Automatic
    override func viewWillDisappear(_ animated: Bool) { super.viewWillAppear(animated)
        self.splitViewController?.preferredDisplayMode = .automatic
    }
    
    // On Row Selected:
    //  - Invoke Delegate
    //  - Notify Observers
    //  - Remember Row as Last Selected
    func onRowSelected(at indexPath: IndexPath) {
        let note = fetchedResultsController.object(at: indexPath)
        
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
}

// MARK: - View Stuff
extension NoteTableViewController {
    
    // Setup UIView:
    //  - Creates a UIBarButtonItem so that Users can ...
    func setupUIView() {
        
        /* create */
        //let wikiButton = UIBarButtonItem(title: "Wiki", style: .plain, target: self, action: #selector(wikiButtonAction))
        //let membersButton = UIBarButtonItem(title: "Members", style: .plain, target: self, action: #selector(membersButtonAction))
        
        /* set */
        //navigationItem.rightBarButtonItems = [wikiButton, membersButton]
        
        
        /* Test Data */
        Notebook.deleteAll()
        let notebook = Notebook.create(name: "Primera libreta")
        let note1   = Note.create(title: "F", content: "Note1")!
        let note2   = Note.create(title: "C", content: "Note2")!
        let note3   = Note.create(title: "B", content: "Note3")!
        let note4   = Note.create(title: "E", content: "Note4")!
        let note5   = Note.create(title: "A", content: "Note5")!
        let note6   = Note.create(title: "D", content: "Note6")!
        notebook!.add(notes: [note1, note2, note3, note4, note5, note6])
        notebook?.save()
        
        /* Fetch All Notes */
        let (ctx, fetchRequest) = Note.fetchRequestForAllResults()
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortByTitle]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
        
        
        
        /* */
        navigationController?.toolbar.isHidden = false
        navigationController?.isToolbarHidden = false
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let photoBarButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: nil)
        let menuBarButton = UIBarButtonItem(image: UIImage(named: "dots-horizontal")!, style: .done, target: nil, action: nil)
        self.setToolbarItems([flexibleSpace, menuBarButton], animated: false)
        
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItems = [photoBarButton]
    }
    @objc func wikiButtonAction() { DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
        //self.onDisplayWiki()
    })}
    
    // Table View Delegate Functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return(fetchedResultsController.sections!.count)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(fetchedResultsController.sections![section].numberOfObjects)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* set */
        let cellId  = "HouseCell"
        let cell    = tableView.dequeueReusableCell(withIdentifier: cellId)
            ?? UITableViewCell(style: .default, reuseIdentifier: cellId)
        
        /* donde */
        return(cell)
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        /* set */
        let note = fetchedResultsController.object(at: indexPath)
        
        /* set */
        cell.textLabel?.text = note.title
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.onRowSelected(at: indexPath)
    }
    
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
}

// NSFetchedResultsController Delegate
extension NoteTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
