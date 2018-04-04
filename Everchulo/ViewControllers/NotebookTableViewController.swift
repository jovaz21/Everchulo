//
//  NotebookTableViewController.swift
//  Everchulo
//
//  Created by ATEmobile on 4/4/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

import UIKit
import CoreData

// MARK: - Controller Stuff
class NotebookTableViewController: UITableViewController {
    let notebook: Notebook
    
    // MARK: - Properties
    var fetchedResultsController: NSFetchedResultsController<Notebook>!
    
    // MARK: - Init
    init(notebook: Notebook) {
        
        /* set */
        self.notebook = notebook
        
        /* set */
        super.init(style: UITableViewStyle.plain)
        self.title = i18NString("NotebookTableViewController.title")
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
        let notebook = self.fetchedResultsController.object(at: indexPath)
        let notebookDetailVC = NotebookDetailViewController(notebook: notebook)
        self.navigationController?.pushViewController(notebookDetailVC, animated: true)
    }
    
    // Action Buttons
    var backButtonItem: UIBarButtonItem!
    var closeButtonItem: UIBarButtonItem!
}

// MARK: - View Stuff
extension NotebookTableViewController {
    
    // Setup UIView:
    //  - Creates a UIBarButtonItem so that Users can ...
    func setupUIView() {
        
        /* NAVIGATIONBAR */
        self.closeButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancelAction))
        
        self.navigationItem.leftBarButtonItem = self.closeButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor = Styles.activeColor
        
        // Fetch All Notebooks
        self.fetchAllNotebooks()
    }
    @objc func cancelAction() {
        self.presentingViewController?.dismiss(animated: false)
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
    
    // MARK: - Table View DISPLAY Delegate Functions
    
    /* SECTIONS */
    override func numberOfSections(in tableView: UITableView) -> Int { return(1) }
    
    /* ROWS */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(fetchedResultsController.sections![section].numberOfObjects)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* set */
        let cellId  = "NotebookCell"
        let cell    = tableView.dequeueReusableCell(withIdentifier: cellId)
            ?? UITableViewCell(style: .default, reuseIdentifier: cellId)
        
        /* set */
        let notebook = fetchedResultsController.object(at: indexPath)
        
        /* set */
        cell.imageView?.image = UIImage(named: "notebook")
        cell.textLabel?.text = "\(notebook.name ?? "") (\(notebook.activeNotes.count))"
        cell.tintColor = Styles.activeColor
        
        /* donde */
        return(cell)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
            self.onRowSelected(at: indexPath)
        })
    }
}

// NSFetchedResultsController Delegate
extension NotebookTableViewController: NSFetchedResultsControllerDelegate {
    
    // Feched Results Did Changed
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}
