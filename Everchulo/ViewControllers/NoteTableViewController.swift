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

        /* Test Data */
        if (DataManager.getenv() != .testing) {
            Notebook.deleteAll()
            let notebook1 = Notebook.create(name: "Primera libreta")
            _ = Notebook.create(name: "Segunda libreta")
            _ = Notebook.create(name: "Tercera libreta")
            //let note1   = Note.create(title: "Lorem ipsum 1/6", content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam sit amet purus id ex consectetur congue. Nulla ullamcorper mauris ac suscipit eleifend. Aliquam suscipit vehicula dapibus. Suspendisse a varius elit, ut consequat purus. Sed massa arcu, dictum nec ante porta, consequat hendrerit leo. Maecenas risus dolor, aliquam sed sagittis nec, tincidunt sed tellus. Nulla nisl velit, dictum aliquam scelerisque id, dignissim in justo. Praesent eu efficitur nunc. In hac habitasse platea dictumst. Aliquam blandit id ante imperdiet dignissim. Sed fermentum aliquam sapien id tempus. Sed sed nisl vitae velit scelerisque pellentesque.")!
            let note1   = Note.create(notebook1!, title: "Lorem ipsum 1/6", content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ")!;note1.setActive()
            let note2   = Note.create(notebook1!, title: "Lorem ipsum 2/6", content: "Cras ultrices lorem eget dolor finibus eleifend. Suspendisse bibendum tempus nisi eleifend dictum. Suspendisse potenti. Aenean augue mauris, tempor sit amet orci eu, auctor porta elit. Donec quam metus, lacinia eu urna at, blandit eleifend lorem. Integer semper diam cursus, convallis tortor eget, tempor ipsum. Ut id lorem porttitor, luctus velit at, aliquet eros. Nunc condimentum sagittis est ut varius.")!;note2.setActive()
            let note3   = Note.create(notebook1!, title: "Lorem ipsum 3/6", content: "Aenean venenatis turpis porta, dictum elit at, posuere quam. Donec fermentum, nulla vel facilisis iaculis, nisi dolor dictum massa, a tincidunt sem sem ac lacus. Cras sit amet laoreet mi, at volutpat mauris. Mauris blandit convallis enim id semper. Mauris et odio ligula. Nam lobortis a elit non semper. Nullam ac viverra enim, semper dictum sem. Integer lobortis eget mi ac eleifend. Aenean eget scelerisque mauris. Vestibulum turpis ligula, elementum vitae hendrerit eu, interdum at mauris.")!;note3.setActive()
            //let note4   = Note.create(notebook1!, title: "Lorem ipsum 4/6", content: "Sed eleifend id ipsum non vestibulum. Mauris cursus nisi eget lorem laoreet commodo. Sed placerat quam sed quam congue condimentum. Vivamus eget lorem mauris. In feugiat nunc sit amet tortor condimentum volutpat. Etiam consequat odio velit, mattis porttitor dolor porttitor ac. Aliquam a mi augue. Aliquam id lacus laoreet, suscipit nunc ac, pharetra quam. In ut elit nec sem tempor tempus. Morbi velit est, finibus at magna at, blandit commodo ex.")!;note4.setActive()
            //let note5   = Note.create(notebook1!, title: "Lorem ipsum 5/6", content: "Sed sodales magna eu mauris finibus, eu lacinia nunc condimentum. Vestibulum ornare nisi eros, ac lacinia erat sagittis et. Proin facilisis sed ex sit amet convallis. In scelerisque finibus quam vel placerat. Quisque posuere consequat ornare. Phasellus venenatis risus ac turpis blandit blandit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Integer vel tincidunt ipsum. Nam id odio fringilla orci scelerisque porta. Ut non est eu massa efficitur pretium eu venenatis nulla. Fusce volutpat velit eget tortor pharetra, sed venenatis nisl sollicitudin. Sed tincidunt urna vel egestas ullamcorper. Nam gravida tellus quis urna fermentum varius.")!;note5.setActive()
            //let note6   = Note.create(notebook1!, title: "Lorem ipsum 6/6", content: "Nullam mi massa, ullamcorper nec interdum at, volutpat convallis ipsum. Etiam in augue non velit auctor feugiat id eget urna. Sed fringilla, quam in lobortis auctor, dui lacus commodo mi, eget interdum ipsum velit at felis. Ut imperdiet mattis nisl et sollicitudin. Suspendisse tincidunt vel est ullamcorper porta. Suspendisse vel nunc quis erat tincidunt faucibus non at nunc. Nullam scelerisque, tortor eget malesuada interdum, nunc quam commodo velit, et lacinia magna leo non enim. Suspendisse consequat in lacus eu lacinia. In in purus in dui rutrum accumsan. Donec erat neque, mollis eget feugiat et, venenatis sed libero.")!;note6.setActive()
            let note7   = Note.create(notebook1!, title: "Nota Borrada", content: "Un ejemplo de nota enviada a la papelera")!
            note7.moveToTrash()
            notebook1?.setActive()
            notebook1?.save()
            print("!!!TEST NOTEBOOK", notebook1!.objectID, notebook1!)
        }
        
        // Fetch All
        self.fetchAll()
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
    
    // Fetch Data
    func fetchAll() {
        fetchAllNotebooks()
        fetchAllNotes()
    }
    func fetchAllNotebooks() {
        let (ctx, fetchRequest) = Notebook.fetchRequestForAllResults()
        let sortByStatus = NSSortDescriptor(key: "status", ascending: true, selector: nil)
        let sortByName = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        fetchRequest.sortDescriptors = [sortByStatus, sortByName]
        self.fetchedNotebooksController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedNotebooksController.delegate = self
        try! self.fetchedNotebooksController.performFetch()
    }
    func fetchAllNotes() {
        let (ctx, fetchRequest) = Note.fetchRequestForAllResults()
        let sortByNotebookCriteria = NSSortDescriptor(key: "notebookSortCriteria", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        fetchRequest.sortDescriptors = [sortByNotebookCriteria, sortByTitle]
        self.fetchedNotesController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ctx, sectionNameKeyPath: "notebookName", cacheName: nil)
        self.fetchedNotesController.delegate = self
        try! self.fetchedNotesController.performFetch()
    }
    
    // Get Notebook(s)/Note(s)
    func getNotebooks() -> [Notebook] {
        let notebooks = Notebook.listAll().filter() {
        //let notebooks = fetchedNotebooksController.fetchedObjects?.filter() {
            return($0.activeNotes.count > 0)
        }
        return(notebooks)
        //return(notebooks!)
    }
    func getNotebook(section: Int) -> Notebook? {
        print("!!!<NoteTableViewController> getNotebook: About to getNotebook at section=", section)
        let notebooks = self.getNotebooks()
        if (section >= notebooks.count) {
            return(nil)
        }
        let notebook = notebooks[section]
        print("!!!<NoteTableViewController> getNotebook: Got notebook=", notebook)
        return(notebook)
    }
    func getNote(section: Int, row: Int) -> Note? {
        print("!!!<NoteTableViewController> getNote: About to getNote at section=", section, ", row=", row)
        let notebook = self.getNotebook(section: section)
        if (notebook == nil) {
            return(nil)
        }
        let sortedNotes = notebook!.sortedNotes
        print("!!!<NoteTableViewController> getNote: Got sortedNotes=", sortedNotes)
        if (row >= sortedNotes.count) {
            return(nil)
        }
        return(sortedNotes[row])
    }
    
    // MARK: - Table View DISPLAY Delegate Functions
    
    /* SECTIONS */
    override func numberOfSections(in tableView: UITableView) -> Int {
        print("!!! numberOfSections: ", fetchedNotesController.sections!.count)
        return(fetchedNotesController.sections!.count)
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let foundNotebook = self.getNotebook(section: section)
        
        /* set */
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: SECTIONHEADER_HEIGHT))
        backView.layer.insertSublayer(Styles.whiteBackgroundGradientLayerForView(backView), at: 0)
        
        /* check */
        guard let notebook = foundNotebook else {
            return(backView)
        }
        
        /* ICON */
        let icon = UIImageView()
        icon.image = UIImage(named: "notebook")!.withRenderingMode(.alwaysTemplate)
        icon.tintColor = UIColor.darkGray
        
        /* LABEL */
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.darkGray
        label.text = notebook.name?.uppercased()
        
        /* BUTTON */
        let button = UIButton(type: .contactAdd)
        button.tintColor = Styles.activeColor
        button.layer.setValue(notebook, forKey: "notebook")
        button.addTarget(self, action: #selector(newNotebookNoteAction), for: UIControlEvents.primaryActionTriggered)
        button.isHidden = (notebook.isActive())
        
        /* set */
        icon.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        /* add */
        backView.addSubview(icon)
        backView.addSubview(label)
        backView.addSubview(button)
        
        /* VIEWS */
        let viewDict = ["icon": icon, "label": label, "button": button]
        
        // CONSTRAINTS:
        // - Horizontals
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-8-[icon]-5-[label]", options: [], metrics: nil, views: viewDict)
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "[button]-20-|", options: [], metrics: nil, views: viewDict))
        // - Verticals
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[label]-0-|", options: [], metrics: nil, views: viewDict))
        constraints.append(NSLayoutConstraint(item: icon, attribute: .centerY, relatedBy: .equal, toItem: label, attribute: .centerY, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: label, attribute: .centerY, multiplier: 1, constant: 0))
        
        /* set */
        backView.addConstraints(constraints)
        
        /* done */
        return(backView)
    }
    @IBAction func newNotebookNoteAction(sender: UIButton) { DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
        self.onNewNote((sender.layer.value(forKey: "notebook") as! Notebook))
    })}
    
    /* ROWS */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("!!! numberOfRowsInSection: ", section, fetchedNotesController.sections![section].numberOfObjects)
        return(fetchedNotesController.sections![section].numberOfObjects)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cellId  = "NoteTableViewCell"
        //let cell    = tableView.dequeueReusableCell(withIdentifier: cellId) as? NoteTableViewCell
        //            ?? NoteTableViewCell.newLoadedCell
        let cell = NoteTableViewCell.newLoadedCell
        
        /* set */
        print("!!!<NoteTableViewController> cellForRowAt: About to getNote at indexPath=", indexPath)
        let foundNote = self.getNote(section: indexPath.section, row: indexPath.row)
        print("!!!<NoteTableViewController> cellForRowAt: foundNote=", foundNote as Any)
        
        /* set */
        guard let note = foundNote else {
            return(cell)
        }
        
        /* set */
        cell.titleLabel.text    = note.title
        cell.dateLabel.text     = "23 mar'18"
        cell.contentLabel.text  = note.content
        
        /* set */
        cell.setImages(images: [UIImage]())
        cell.cellDelegate = self
        
        /* TEST */
        print("!!!CELL FOR ROW AT: row=", indexPath.row, ", title='", note.title ?? "", "'")
        if (indexPath.row == 2) {
            cell.setImages(images: [UIImage(named: "Image_0")!,UIImage(named: "Image_1")!,UIImage(named: "Image_2")!,UIImage(named: "Image_3")!,UIImage(named: "Image_4")!])
        }

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
        self.onRowSelected(at: indexPath)
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
            var notebooks   = self.getNotebooks()
            let notebook    = notebooks[indexPath.section]
            var notes       = notebook.sortedNotes
            let note        = notes[indexPath.row]
            
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
}

// MARK: NSFetchedResultsController Delegate
extension NoteTableViewController: NSFetchedResultsControllerDelegate {
    
    // Begin Updates on UITableView
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("!!!controllerWillChangeContent: numberOfSections", self.tableView.numberOfSections)
        var i = 0
        while (i < self.tableView.numberOfSections) {
            print("!!!controllerWillChangeContent: numberOfObjects[", i, "]=", self.tableView.numberOfRows(inSection: i))
            i = i + 1
        }
        self.tableView.beginUpdates()
    }
    
    // Sections Inserted|Deleted
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        print("!!!controllerDidChangeSection: Entering, sectionIndex=", sectionIndex, "controllerSectionsCount=", controller.sections?.count ?? 0, ", tableSectionsCount=", self.tableView.numberOfSections)
        switch (type) {
        case .insert:
            print("!!!controllerDidChangeSection: INSERT")
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .none)
            break
        case .delete:
            print("!!!controllerDidChangeSection: DELETE")
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .none)
            break
        default:
            break
        }
        print("!!!controllerDidChangeSection: Done, tableSectionsCount=", self.tableView.numberOfSections)
    }
    
    // Rows Inserted|Deleted|Updated|Moved
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("!!!controllerDidChangeObject: Entering, anObject=", anObject, ", indexPath=", indexPath as Any, ", newIndexPath=", newIndexPath as Any, "controllerSectionsCount=", controller.sections?.count ?? 0, ", controllerFetchedObjectsCount=", controller.fetchedObjects?.count ?? 0, ", tableSectionsCount=", self.tableView.numberOfSections)
        if (controller == self.fetchedNotebooksController) {
            switch (type) {
            case .insert:
                print("!!!controllerDidChangeObject: INSERT")
                break
            case .delete:
                print("!!!controllerDidChangeObject: DELETE")
                break
            case .update:
                print("!!!controllerDidChangeObject: UPDATE")
                break
            case .move:
                print("!!!controllerDidChangeObject: MOVE")
                break
            }
            print("!!!controllerDidChangeObject: Done (Ignored)")
            return
        }
        switch (type) {
        case .insert:
            let atIndexPath = controller.indexPath(forObject: anObject as! NSFetchRequestResult)!
            print("!!!controllerDidChangeObject: INSERT, atIndexPath=", atIndexPath, ", whereNumberOfRows=", self.tableView.numberOfRows(inSection: atIndexPath.section))
            self.tableView.insertRows(at: [atIndexPath], with: .none)
            print("!!!controllerDidChangeObject: AFTER INSERT, numberOfRows=", self.tableView.numberOfRows(inSection: atIndexPath.section))
            break
        case .delete:
            print("!!!controllerDidChangeObject: DELETE")
            self.tableView.deleteRows(at: [indexPath!], with: .none)
            break
        case .update:
            print("!!!controllerDidChangeObject: <ReloadData>")
            if (newIndexPath != indexPath) {
                print("!!!controllerDidChangeObject: UPDATING from ", indexPath!, " to ", newIndexPath!)
                self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
            }
            break
        case .move:
            print("!!!controllerDidChangeObject: MOVE")
            //if (newIndexPath != indexPath) {
            // He tenido que comentar porque daba error al ignorar un movimiento
            // de (0, 0) a (0, 0) cuando tras crear una Nota 'A' dentro de 'Segunda libreta',
            // cojo y MUEVO esa Nota hacia la 'Primera libreta'
                print("!!!controllerDidChangeObject: MOVING from ", indexPath!, " to ", newIndexPath!)
                self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
            //}
            break;
        }
        print("!!!controllerDidChangeObject: Done (UITableView Updated)")
    }
    
    // End Updates on UITableView
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("!!!controllerDidChangeContent: numberOfSections", self.tableView.numberOfSections)
        
        /* */
        self.tableView.endUpdates()
        self.tableView.reloadData()
        
        /* check */
        if (controller.fetchedObjects!.count <= 0) {
            self.editButtonItem.setHidden(true)
            self.menuBarButtonItem.setHidden(Note.listTrashed().count <= 0)
        }
        else {
            self.editButtonItem.setHidden(false)
            self.menuBarButtonItem.setHidden(false)
        }
        
        /* */
        var i = 0
        while (i < self.tableView.numberOfSections) {
            print("!!!controllerDidChangeContent: numberOfObjects[", i, "]=", self.tableView.numberOfRows(inSection: i))
            i = i + 1
        }
    }
}

// NoteDetailViewController Delegate
extension NoteTableViewController: NoteDetailViewControllerDelegate {
    func noteDetailViewController(_ vc: NoteDetailViewController, willCreateNote note: Note) {
        print("!!!willCreateNote: numberOfSections", self.tableView.numberOfSections)
        var i = 0
        while (i < self.tableView.numberOfSections) {
            print("!!!willCreateNote: numberOfObjects[", i, "]=", self.tableView.numberOfRows(inSection: i))
            i = i + 1
        }
    }
    func noteDetailViewController(_ vc: NoteDetailViewController, didCreateNote note: Note) {
        print("!!!didCreateNote: numberOfSections", self.tableView.numberOfSections)
        var i = 0
        while (i < self.tableView.numberOfSections) {
            print("!!!didCreateNote: numberOfObjects[", i, "]=", self.tableView.numberOfRows(inSection: i))
            i = i + 1
        }
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
