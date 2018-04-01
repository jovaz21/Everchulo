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
    func notebookSelectorTableViewController(_ vc: NotebookSelectorTableViewController, didSelectNotebook notebook: Notebook)
}

// MARK: - Controller Stuff
class NotebookSelectorTableViewController: UITableViewController {
    let model: Note
        
    // MARK: - Properties
    var viewMode: ViewMode = .move
    var fetchedResultsController: NSFetchedResultsController<Notebook>!
    var selectedRow: Int = -1
    var lastTappedRow: Int = -1
    
    // Delegate
    weak var delegate: NotebookSelectorTableViewControllerDelegate?
    
    // MARK: - Init
    init(model: Note) {
        
        /* set */
        self.model = model
        
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
        if (self.viewMode == .select) {
            DispatchQueue.main.async {
                
                /* set */
                self.selectedRow = self.lastTappedRow
                let notebook = self.fetchedResultsController.object(at: IndexPath(row: self.selectedRow, section: 0))
                
                /* delegate */
                if (self.delegate != nil) { // Delegate
                    self.delegate!.notebookSelectorTableViewController(self, didSelectNotebook: notebook)
                }
                
                /* */
                self.presentingViewController?.dismiss(animated: true)
            }
            return
        }
        
        // Declare Alert message
        let dialogMessage = UIAlertController(title: "\(i18NString("NotebookSelectorTableViewController.confirmMsg")) '\(fetchedResultsController.object(at: IndexPath(row: self.lastTappedRow, section: 0)).name!)'?", message: "", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: i18NString("NotebookSelectorTableViewController.moveMsg"), style: .default, handler: { (action) -> Void in
            DispatchQueue.main.async {
                
                /* set */
                self.selectedRow = self.lastTappedRow
                let notebook = self.fetchedResultsController.object(at: IndexPath(row: self.selectedRow, section: 0))

                /* delegate */
                if (self.delegate != nil) { // Delegate
                    self.delegate!.notebookSelectorTableViewController(self, didSelectNotebook: notebook)
                }
                
                /* */
                self.presentingViewController?.dismiss(animated: true)
            }
        })
        ok.setValue(Styles.activeColor, forKey: "titleTextColor")
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: i18NString("es.atenet.app.Cancel"), style: .cancel) { (action) -> Void in
            DispatchQueue.main.async {
                self.tableView.cellForRow(at: IndexPath(row: self.lastTappedRow, section: 0))?.accessoryType = .none
                self.tableView.cellForRow(at: IndexPath(row: self.selectedRow, section: 0))?.accessoryType = .checkmark
                self.lastTappedRow = self.selectedRow
            }
        }
        cancel.setValue(Styles.activeColor, forKey: "titleTextColor")
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
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
    }
    
    // Setup UIView:
    //  - Creates a UIBarButtonItem so that Users can ...
    func setupUIView() {
        
        /* NAVIGATIONBAR */
        self.cancelButtonItem = UIBarButtonItem(title: "X", style: .done, target: self, action: #selector(cancelAction))
        let normalTextAttributes: [NSAttributedStringKey: Any] =
            [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 28.0),
             NSAttributedStringKey.foregroundColor: Styles.activeColor]
        self.cancelButtonItem.setTitleTextAttributes(normalTextAttributes, for: UIControlState.normal)
        self.navigationItem.leftBarButtonItem = self.cancelButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor = Styles.activeColor
        
        self.addNotebookButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNotebookAction))
        self.addNotebookButtonItem.setTitleTextAttributes(normalTextAttributes, for: UIControlState.normal)
        self.navigationItem.rightBarButtonItem = self.addNotebookButtonItem
        self.navigationItem.rightBarButtonItem?.tintColor = Styles.activeColor
        
        // Fetch All Notebooks
        self.fetchAllNotebooks()
    }
    @objc func cancelAction() {
        self.presentingViewController?.dismiss(animated: false)
    }
    @objc func addNotebookAction() {
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
        if (self.model.notebook == notebook) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            self.selectedRow = indexPath.row
            self.lastTappedRow = self.selectedRow
        }
        cell.tintColor = Styles.activeColor
        
        /* donde */
        return(cell)
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (self.lastTappedRow >= 0) {
            let oldIndex = IndexPath(row: self.lastTappedRow, section: 0)
            tableView.cellForRow(at: oldIndex)?.accessoryType = .none
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        return(indexPath)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.lastTappedRow = indexPath.row
        tableView.deselectRow(at: IndexPath(row: self.lastTappedRow, section: 0), animated: true)
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
