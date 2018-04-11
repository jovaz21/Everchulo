//
//  NotebookSelectorTableViewController.swift
//  Everchulo
//
//  Created by ATEmobile on 28/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit
import CoreData

// NotebookSelectorTableViewController Delegate
protocol NotebookSelectorTableViewControllerDelegate: AnyObject {
    func notebookSelectorTableViewController(_ vc: NotebookSelectorTableViewController, didCancel notebook: Notebook, presentingViewController: UIViewController)
    func notebookSelectorTableViewController(_ vc: NotebookSelectorTableViewController, didSelectNotebook notebook: Notebook)
}

// MARK: - Controller Stuff
class NotebookSelectorTableViewController: UITableViewController {
    let notebook: Notebook
        
    // MARK: - Properties
    var viewMode: ViewMode = .move
    var fetchedResultsController: NSFetchedResultsController<Notebook>!
    
    var selectedNotebook: Notebook? = nil
    var lastTappedNotebook: Notebook? = nil
    
    var selectedRow: Int = -1
    var lastTappedRow: Int = -1
    
    // Delegate
    weak var delegate: NotebookSelectorTableViewControllerDelegate?
    
    // MARK: - Init
    init(notebook: Notebook) {
        
        /* set */
        self.notebook = notebook
        
        /* set */
        super.init(style: UITableViewStyle.plain)
        self.title = i18NString("NotebookSelectorTableViewController.\(viewMode.rawValue).title")
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // View Did Load
    override func viewDidLoad() { super.viewDidLoad()
        
        /* setup */
        self.setupUIView()
    }
        
    // View Will Appear
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated) }
        
    // View Will Disappear:
    override func viewWillDisappear(_ animated: Bool) { super.viewWillAppear(animated) }
        
    // On Row Selected:
    func onRowSelected(at indexPath: IndexPath) {
        
        /* check */
        if (self.lastTappedNotebook == self.notebook) {
            return
        }
        
        /* check */
        if (self.viewMode == .select) { DispatchQueue.main.async {
                
            /* set */
            self.selectedNotebook = self.lastTappedNotebook
            self.selectedRow = self.lastTappedRow
            let notebook = self.selectedNotebook!
                
            /* delegate */
            if (self.delegate != nil) { // Delegate
                self.delegate!.notebookSelectorTableViewController(self, didSelectNotebook: notebook)
            }
                
            /* */
            self.presentingViewController?.dismiss(animated: true)
        }}
        
        /* confirm */
        let confirmDialog = makeConfirmDialog(title: "\(i18NString("NotebookSelectorTableViewController.\(self.viewMode.rawValue).confirmMsg")) '\(self.lastTappedNotebook!.name!)'?", message: "", okAction: (
                title:      i18NString("NotebookSelectorTableViewController.moveMsg"),
                style:      .default,
                handler:    { (action) in
                    self.presentingViewController?.dismiss(animated: true)
                    DispatchQueue.main.async {
                    
                        /* set */
                        self.selectedNotebook = self.lastTappedNotebook
                        self.selectedRow = self.lastTappedRow
                        let notebook = self.selectedNotebook!
                    
                        /* delegate */
                        if (self.delegate != nil) { // Delegate
                            self.delegate!.notebookSelectorTableViewController(self,    didSelectNotebook: notebook)
                        }
                    }
            }), cancelAction: (
                title:      i18NString("es.atenet.app.Cancel"),
                style:      .default,
                handler:    { (action) in DispatchQueue.main.async {
                    self.tableView.cellForRow(at: self.fetchedResultsController.indexPath(forObject: self.lastTappedNotebook!)!)?.accessoryType = .none
                    self.tableView.cellForRow(at: self.fetchedResultsController.indexPath(forObject: self.selectedNotebook!)!)?.accessoryType = .checkmark
                    self.lastTappedRow = self.selectedRow
                    self.lastTappedNotebook = self.selectedNotebook
                }}
            )
        )
        
        /* present */
        self.present(confirmDialog, animated: true, completion: nil)
    }
    
    // Action Buttons
    var cancelButtonItem: UIBarButtonItem!
    var addNotebookButtonItem: UIBarButtonItem!
}
    
// MARK: - View Stuff
extension NotebookSelectorTableViewController {
    
    // View Mode
    enum ViewMode: String {
        case select
        case move
        case moveAll
    }
    
    // Setup UIView:
    //  - Creates a UIBarButtonItem so that Users can ...
    func setupUIView() {
        
        /* NAVIGATIONBAR */
        self.cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancelAction))
        self.navigationItem.leftBarButtonItem = self.cancelButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor = Styles.activeColor
        
        self.addNotebookButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNotebookAction))
        let normalTextAttributes: [NSAttributedStringKey: Any] =
            [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 28.0),
             NSAttributedStringKey.foregroundColor: Styles.activeColor]
        self.addNotebookButtonItem.setTitleTextAttributes(normalTextAttributes, for: UIControlState.normal)
        self.navigationItem.rightBarButtonItem = self.addNotebookButtonItem
        self.navigationItem.rightBarButtonItem?.tintColor = Styles.activeColor
        
        // Fetch All Notebooks
        self.fetchAllNotebooks()
    }
    @objc func cancelAction() {
        
        /* cleanup */
        Notebook.listAll().forEach() {
            if ($0.activeNotes.count <= 0) {
                $0.delete()
            }
        }
        
        /* */
        let presentingViewController = self.presentingViewController!
        presentingViewController.dismiss(animated: true)
        
        /* delegate */
        if (self.delegate != nil) { // Delegate
            self.delegate!.notebookSelectorTableViewController(self, didCancel: notebook, presentingViewController: presentingViewController)
        }
    }
    @objc func addNotebookAction() {
        let newNotebookVC = NewNotebookViewController()
        newNotebookVC.delegate = self
        self.present(newNotebookVC.wrappedInNavigation(), animated: true, completion: nil)
    }
    
    // MARK: - Instance Methods
    func fetchAllNotebooks() {
        let (ctx, fetchRequest) = Notebook.fetchRequestForAllResults()
        let sortByName = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        fetchRequest.sortDescriptors = [sortByName]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        try! self.fetchedResultsController.performFetch()
    }
    func setViewMode(_ value: ViewMode) {
        
        /* set */
        self.viewMode = value
        
        /* set */
        self.title = i18NString("NotebookSelectorTableViewController.\(viewMode.rawValue).title")
        
        /* done */
        return
    }
    
    // MARK: - Table View DISPLAY Delegate Functions
    
    /* SECTIONS */
    override func numberOfSections(in tableView: UITableView) -> Int { return(1) }
    
    /* ROWS */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(fetchedResultsController.sections![section].numberOfObjects)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        /* set */
        let cellId  = "NotebookSelectorCell"
        let cell    = tableView.dequeueReusableCell(withIdentifier: cellId)
            ?? UITableViewCell(style: .default, reuseIdentifier: cellId)
        
        /* set */
        let notebook = fetchedResultsController.object(at: indexPath)
        
        /* set */
        cell.imageView?.image = UIImage(named: "notebook")
        cell.textLabel?.text = "\(notebook.name ?? "") (\(notebook.activeNotes.count))"
        
        if (self.notebook == notebook) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            self.selectedRow = indexPath.row
            self.lastTappedRow = self.selectedRow
            
            self.selectedNotebook = notebook
            self.lastTappedNotebook = self.selectedNotebook
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        cell.tintColor = Styles.activeColor
        
        /* donde */
        return(cell)
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        //if (self.lastTappedRow >= 0) {
        //    let oldIndex = IndexPath(row: self.lastTappedRow, section: 0)
        //    tableView.cellForRow(at: oldIndex)?.accessoryType = .none
        //}
        if (self.lastTappedNotebook != nil) {
            let oldIndex = self.fetchedResultsController.indexPath(forObject: self.lastTappedNotebook!)!
            tableView.cellForRow(at: oldIndex)?.accessoryType = .none
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        return(indexPath)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.lastTappedRow = indexPath.row
        self.lastTappedNotebook = self.fetchedResultsController.object(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
            self.onRowSelected(at: indexPath)
        })
    }
}

// NSFetchedResultsController Delegate
extension NotebookSelectorTableViewController: NSFetchedResultsControllerDelegate {
    
    // Feched Results Did Changed
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}

// NewNotebookViewController Delegate
extension NotebookSelectorTableViewController: NewNotebookViewControllerDelegate {
    
    // New Notebook Did Create
    func newNotebookViewController(_ vc: NewNotebookViewController, didCreateNotebook notebook: Notebook) {
        
        /* check */
        if (self.viewMode == .select) {
            
            /* delegate */
            if (self.delegate != nil) { // Delegate
                self.delegate!.notebookSelectorTableViewController(self, didSelectNotebook: notebook)
            }
            
            /* */
            self.presentingViewController?.dismiss(animated: false)
            return
        }
        
        /* */
        print("!!!<NotebookSelectorTableViewController> didCreateNotebook: notebook=", notebook)
    }
}
