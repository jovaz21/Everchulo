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
    
    // On New Note
    func onNewNote(_ notebook: Notebook? = nil) {
        if (notebook == nil) {
            print("NUEVA NOTA <Sin Notebook>")
        }
        else {
            let objectID    = notebook!.objectID
            let name        = notebook!.name!
            print("NUEVA NOTA <'\(name)', '\(objectID)>'")
        }
    }
    
    // Height Constants
    let SECTIONHEADER_HEIGHT    = CGFloat(60)
    let ROW_HEIGHT              = CGFloat(80)
}

// MARK: - View Stuff
extension NoteTableViewController {
    
    // Setup UIView:
    //  - Creates a UIBarButtonItem so that Users can ...
    func setupUIView() {
        
        /* init */
        //tableView.estimatedRowHeight = ROW_HEIGHT
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = SECTIONHEADER_HEIGHT
        
        /* NAVIGATIONBAR */
        let newNoteButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(newNoteAction))
        newNoteButton.tintColor = Styles.activeColor
        self.editButtonItem.title = i18NString("com.apple.UIKit.Edit")
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor = Styles.activeColor
        //self.navigationItem.rightBarButtonItems = [self.editButtonItem]
        
        /* TOOLBAR */
        navigationController?.toolbar.isHidden  = false
        navigationController?.isToolbarHidden   = false
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let menuBarButton = UIBarButtonItem(image: UIImage(named: "dots-horizontal")!, style: .done, target: self, action: #selector(displayNoteMenuAction))
        menuBarButton.tintColor = Styles.activeColor
        self.setToolbarItems([menuBarButton, flexibleSpace, newNoteButton], animated: false)
        
        /* Test Data */
        Notebook.deleteAll()
        let notebook = Notebook.create(name: "Primera libreta")
        //let note1   = Note.create(title: "Lorem ipsum 1/6", content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam sit amet purus id ex consectetur congue. Nulla ullamcorper mauris ac suscipit eleifend. Aliquam suscipit vehicula dapibus. Suspendisse a varius elit, ut consequat purus. Sed massa arcu, dictum nec ante porta, consequat hendrerit leo. Maecenas risus dolor, aliquam sed sagittis nec, tincidunt sed tellus. Nulla nisl velit, dictum aliquam scelerisque id, dignissim in justo. Praesent eu efficitur nunc. In hac habitasse platea dictumst. Aliquam blandit id ante imperdiet dignissim. Sed fermentum aliquam sapien id tempus. Sed sed nisl vitae velit scelerisque pellentesque.")!
        let note1   = Note.create(title: "Lorem ipsum 1/6", content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ")!
        let note2   = Note.create(title: "Lorem ipsum 2/6", content: "Cras ultrices lorem eget dolor finibus eleifend. Suspendisse bibendum tempus nisi eleifend dictum. Suspendisse potenti. Aenean augue mauris, tempor sit amet orci eu, auctor porta elit. Donec quam metus, lacinia eu urna at, blandit eleifend lorem. Integer semper diam cursus, convallis tortor eget, tempor ipsum. Ut id lorem porttitor, luctus velit at, aliquet eros. Nunc condimentum sagittis est ut varius.")!
        let note3   = Note.create(title: "Lorem ipsum 3/6", content: "Aenean venenatis turpis porta, dictum elit at, posuere quam. Donec fermentum, nulla vel facilisis iaculis, nisi dolor dictum massa, a tincidunt sem sem ac lacus. Cras sit amet laoreet mi, at volutpat mauris. Mauris blandit convallis enim id semper. Mauris et odio ligula. Nam lobortis a elit non semper. Nullam ac viverra enim, semper dictum sem. Integer lobortis eget mi ac eleifend. Aenean eget scelerisque mauris. Vestibulum turpis ligula, elementum vitae hendrerit eu, interdum at mauris.")!
        let note4   = Note.create(title: "Lorem ipsum 4/6", content: "Sed eleifend id ipsum non vestibulum. Mauris cursus nisi eget lorem laoreet commodo. Sed placerat quam sed quam congue condimentum. Vivamus eget lorem mauris. In feugiat nunc sit amet tortor condimentum volutpat. Etiam consequat odio velit, mattis porttitor dolor porttitor ac. Aliquam a mi augue. Aliquam id lacus laoreet, suscipit nunc ac, pharetra quam. In ut elit nec sem tempor tempus. Morbi velit est, finibus at magna at, blandit commodo ex.")!
        let note5   = Note.create(title: "Lorem ipsum 5/6", content: "Sed sodales magna eu mauris finibus, eu lacinia nunc condimentum. Vestibulum ornare nisi eros, ac lacinia erat sagittis et. Proin facilisis sed ex sit amet convallis. In scelerisque finibus quam vel placerat. Quisque posuere consequat ornare. Phasellus venenatis risus ac turpis blandit blandit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Integer vel tincidunt ipsum. Nam id odio fringilla orci scelerisque porta. Ut non est eu massa efficitur pretium eu venenatis nulla. Fusce volutpat velit eget tortor pharetra, sed venenatis nisl sollicitudin. Sed tincidunt urna vel egestas ullamcorper. Nam gravida tellus quis urna fermentum varius.")!
        let note6   = Note.create(title: "Lorem ipsum 6/6", content: "Nullam mi massa, ullamcorper nec interdum at, volutpat convallis ipsum. Etiam in augue non velit auctor feugiat id eget urna. Sed fringilla, quam in lobortis auctor, dui lacus commodo mi, eget interdum ipsum velit at felis. Ut imperdiet mattis nisl et sollicitudin. Suspendisse tincidunt vel est ullamcorper porta. Suspendisse vel nunc quis erat tincidunt faucibus non at nunc. Nullam scelerisque, tortor eget malesuada interdum, nunc quam commodo velit, et lacinia magna leo non enim. Suspendisse consequat in lacus eu lacinia. In in purus in dui rutrum accumsan. Donec erat neque, mollis eget feugiat et, venenatis sed libero.")!
        notebook!.add(notes: [note1, note2, note3, note4, note5, note6])
        notebook?.save()
        
        /* Fetch All Notes */
        let (ctx, fetchRequest) = Note.fetchRequestForAllResults()
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortByTitle]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ctx, sectionNameKeyPath: "notebook", cacheName: nil)
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }
    @objc func newNoteAction() { DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
        self.onNewNote()
    })}
    @objc func displayNoteMenuAction() { DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
        
        /* menu */
        let actionSheetMenu = makeActionSheetMenu(title: nil, message: nil, items:
            (
                title:      i18NString("NoteTableViewController.notebooksSettingsMsg"),
                style:      .default,
                image:      UIImage(named: "notebook"),
                handler:    { (alertAction) in
                    //self.present(imagePicker, animated: true, completion: nil)
                }
            ),
            (
                title:      i18NString("es.atenet.app.Cancel"),
                style:      .cancel,
                image:      nil,
                handler:    nil
            )
        )

        /* present */
        self.present(actionSheetMenu, animated: true, completion: nil)
    })}
    
    // MARK: - Table View DISPLAY Delegate Functions
    
    /* SECTIONS */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return(fetchedResultsController.sections!.count)
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let notes       = fetchedResultsController.sections![section].objects as! [Note]
        let notebook    = notes.first?.notebook
        
        /* set */
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: SECTIONHEADER_HEIGHT))
        
        /* ICON */
        let icon = UIImageView()
        icon.image = UIImage(named: "notebook")!.withRenderingMode(.alwaysTemplate)
        icon.tintColor = UIColor.darkGray
        
        /* LABEL */
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.darkGray
        label.text = notebook?.name?.uppercased()
        
        /* BUTTON */
        let button = UIButton(type: .contactAdd)
        button.tintColor = UIColor(red: 34.0/255.0, green: 177.0/255.0, blue: 76.0/255.0, alpha: 1)
        //button.tintColor = UIColor.gray
        button.layer.setValue(notebook, forKey: "notebook")
        button.addTarget(self, action: #selector(newNotebookNoteAction), for: UIControlEvents.primaryActionTriggered)
        
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
        return(fetchedResultsController.sections![section].numberOfObjects)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* set */
        let cellId  = "NoteTableViewCell"
        let cell    = tableView.dequeueReusableCell(withIdentifier: cellId) as? NoteTableViewCell
            ?? NoteTableViewCell(style: .default, reuseIdentifier: cellId)
        
        /* set */
        let note = fetchedResultsController.object(at: indexPath)
        
        /* set */
        cell.titleLabel.text    = note.title
        cell.dateLabel.text     = "23 mar'18"
        cell.contentLabel.text  = note.content
        
        /* test */
        if (indexPath.row == 2) {
            cell.setImages(images: [UIImage(named: "Image_0")!,UIImage(named: "Image_1")!,UIImage(named: "Image_2")!,UIImage(named: "Image_3")!,UIImage(named: "Image_4")!])
        }

        /* donde */
        return(cell)
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
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return(true)
     }
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            fetchedResultsController.object(at: indexPath).delete(commit: true)
        }
     }
}

// NSFetchedResultsController Delegate
extension NoteTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            
            /* reload */
            self.tableView.reloadData()
            
            /* check */
            if (self.fetchedResultsController.fetchedObjects!.count <= 0) {
                self.navigationItem.leftBarButtonItem?.isEnabled = false
                self.navigationItem.leftBarButtonItem?.tintColor = UIColor.clear
            }
            else {
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                self.navigationItem.leftBarButtonItem?.tintColor = Styles.activeColor
            }
        }
    }
}
