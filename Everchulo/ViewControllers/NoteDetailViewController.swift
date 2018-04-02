//
//  NoteDetailViewController.swift
//  Everchulo
//
//  Created by ATEmobile on 27/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

// NoteDetailViewControllerDelegate: class {
protocol NoteDetailViewControllerDelegate: AnyObject {
    func noteDetailViewController(_ vc: NoteDetailViewController, willCreateNote note: Note)
    func noteDetailViewController(_ vc: NoteDetailViewController, didCreateNote note: Note)
}

// MARK: - Controller Stuff
class NoteDetailViewController: UIViewController {
    var viewMode: ViewMode = .edit
    var notebook: Notebook? = nil
    var note: Note? = nil
    
    // Delegate
    weak var delegate: NoteDetailViewControllerDelegate?
    
    // MARK: - Init
    init(notebook: Notebook? = nil, note: Note? = nil) {
        self.notebook = notebook
        self.note = note
        
        /* set */
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        self.title = ""
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // View Is Loaded:
    // Setup UIView Layer
    override func viewDidLoad() { super.viewDidLoad()
        self.setupUIView()
    }
    
    // View Will Appear:
    //  - Paint UIView
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated)
        
        /* check */
        if (self.notebook == nil) {
            self.notebook = Notebook.getActive()
            
            /* check */
            if (self.notebook == nil) {
                self.notebook = Notebook.create(name: "Primera libreta")
                self.notebook?.setActive()
            }
        }
        
        /* check */
        if (self.note == nil) {
            
            /* New Note */
            self.viewMode = .new
            
            /* create */
            self.note = Note.create(notebook!)!
        }
        
        // Paint UIView
        self.paintUIView()
    }
    
    override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated)
        // Paint UIView
        self.paintUIView()
    }
    
    // MARK: - Outlets
    @IBOutlet weak var notebookImageView: UIImageView!
    @IBOutlet weak var selectTextButton: UIButton!
    @IBOutlet weak var selectIcon: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextView!
    
    // On Select Notebook
    func onSelectNotebook() {
        
        /* set */
        let notebookSelectorVC = NotebookSelectorTableViewController(model: self.note!)
        notebookSelectorVC.delegate = self
        
        /* check */
        if (self.viewMode == .new) {
            notebookSelectorVC.setViewMode(.select)
        }
        
        /* show */
        self.present(notebookSelectorVC.wrappedInNavigation(), animated: true)
    }
    
    // On Note Done
    func onNoteDone() {
        let titleText = self.titleTextField.text
        let contentText = self.contentTextField.text
        
        /* focus */
        if (self.titleTextField.isFirstResponder) {
            self.titleTextField.resignFirstResponder()
        }
        if (self.contentTextField.isFirstResponder) {
            self.contentTextField.resignFirstResponder()
        }
        
        /* check */
        if (titleText!.count > 0) {
            self.note!.title = titleText
        }
        if (contentText!.count > 0) {
            self.note!.content = contentText
        }
        
        /* check */
        if ((self.note!.title == nil) && (self.note!.content == nil)) {
            
            /* delete */
            self.note!.delete()
            
            /* cleanup */
            Notebook.listAll().forEach() {
                if ($0.activeNotes.count <= 0) {
                    $0.delete()
                }
            }
            
            /* done */
            self.presentingViewController?.dismiss(animated: false)
            return
        }
        
        /* check */
        if (self.note!.title == nil) {
            self.note!.title = self.note!.content
        }
        if (self.note!.content == nil) {
            self.note!.content = self.note!.title
        }
            
        /* save */
        print("!!!<NoteDetailViewController> onNoteDone: Setting New Note ACTIVE, notebookActiveNotesCount=", self.note!.notebook!.activeNotes.count)
        if (self.delegate != nil) { // Delegate
            if (self.viewMode == .new) {
                self.delegate!.noteDetailViewController(self, willCreateNote: self.note!)
            }
        }
        if (!self.note!.notebook!.isActive()) {
            self.note!.notebook!.setActive()
            self.note!.notebook!.save()
        }
        if (!self.note!.isActive()) {
            self.note!.setActive()
        }
        print("!!!<NoteDetailViewController> onNoteDone: Saving Data, notebookActiveNotesCount=", self.note!.notebook!.activeNotes.count)
        self.note!.save()
        print("!!!<NoteDetailViewController> onNoteDone: New Note Added, notebookActiveNotesCount=", self.note!.notebook!.activeNotes.count)
        if (self.delegate != nil) { // Delegate
            if (self.viewMode == .new) {
                self.delegate!.noteDetailViewController(self, didCreateNote: self.note!)
            }
        }
        
        /* cleanup */
        Notebook.listAll().forEach() {
            if ($0.activeNotes.count <= 0) {
                $0.delete()
            }
        }

        /* check */
        if (self.viewMode == .new) {
            self.presentingViewController?.dismiss(animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    // Paint UIView
    //  - Map Model Properties with View Data
    //  - Set UIView Data
    func paintUIView() {
        
        /* set */
        self.setUIViewData(NoteViewData(
            notebookName:   note!.notebook?.name,
            title:          note!.title,
            content:        note!.content
        ))
        
        /* focus */
        if (self.viewMode == .new) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
                self.contentTextField.becomeFirstResponder()
            })
        }
        
        /* keyboard */
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeKeyboard))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
    }
    @objc func closeKeyboard() {
        if (self.titleTextField.isFirstResponder) {
            self.titleTextField.resignFirstResponder()
        }
        else if (self.contentTextField.isFirstResponder) {
            self.contentTextField.resignFirstResponder()
        }
        else {
            self.view.resignFirstResponder()
        }
    }
    
    // Action Buttons
    var okButtonItem: UIBarButtonItem!
    var infosButtonItem: UIBarButtonItem!
    var menuBarButtonItem: UIBarButtonItem!
}

// MARK: - View Stuff
struct NoteViewData {
    let notebookName:   String?
    let title:          String?
    let content:        String?
}
extension NoteDetailViewController {
    
    // View Mode
    enum ViewMode: String {
        case new
        case edit
    }
    
    // Setup UIView
    func setupUIView() {
        
        // NOTEBOOOK SELECTOR
        notebookImageView.image = UIImage(named: "notebook")!.withRenderingMode(.alwaysTemplate)
        notebookImageView.tintColor = UIColor.gray
        
        selectTextButton.tintColor = Styles.activeColor
        selectTextButton.setTitleColor(Styles.activeColor, for: UIControlState.normal)
        selectTextButton.addTarget(self, action: #selector(selectNotebookAction), for: UIControlEvents.touchUpInside)
        
        selectIcon.image = UIImage(named: "chevron-down")!.withRenderingMode(.alwaysTemplate)
        selectIcon.tintColor = Styles.activeColor
        
        // TEXT FIELDS
        titleTextField.tintColor = Styles.activeColor
        titleTextField.placeholder = i18NString("NoteDetailsViewController.titlePlaceHolder")
        
        contentTextField.tintColor = Styles.activeColor
        if (self.viewMode == .new) {
            contentTextField.placeholder = i18NString("NoteDetailsViewController.contentPlaceHolder")
        }
        
        /* NAVIGATIONBAR */
        if (self.viewMode == .new) {
            self.okButtonItem = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(noteDoneAction))
            self.navigationItem.leftBarButtonItem = self.okButtonItem
            self.navigationItem.leftBarButtonItem?.tintColor = Styles.activeColor
        }
        else {
            self.okButtonItem = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(noteDoneAction))
            self.navigationItem.leftBarButtonItem = self.okButtonItem
            self.navigationItem.leftBarButtonItem?.tintColor = Styles.activeColor
        }
        self.menuBarButtonItem = UIBarButtonItem(image: UIImage(named: "dots-horizontal")!, style: .done, target: self, action: #selector(displayNoteMenuAction))
        self.menuBarButtonItem.tintColor = Styles.activeColor
        self.infosButtonItem = UIBarButtonItem(image: UIImage(named: "information-outline")!, style: .done, target: self, action: #selector(displayInfosAction))
        self.infosButtonItem.tintColor = Styles.activeColor
        self.navigationItem.rightBarButtonItems = [self.menuBarButtonItem, self.infosButtonItem]
    }
    @objc func selectNotebookAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
            self.onSelectNotebook()
        })
    }
    @objc func noteDoneAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
            self.onNoteDone()
        })
    }
    @objc func displayNoteMenuAction() {
    }
    @objc func displayInfosAction() {
    }
    
    // Set UIView Data
    //  - Makes UIView Display ViewData
    func setUIViewData(_ data: NoteViewData) {
        print("!!! setUIViewData: Entering, data=", data)
        self.selectTextButton.setTitle(data.notebookName, for: .normal)
        if (data.title != nil) {
            self.titleTextField.text = data.title
        }
        if (data.content != nil) {
            self.contentTextField.text = data.content
        }
        print("!!! setUIViewData: Done")
    }
    
    // MARK: - Instance Methods
    func setViewMode(_ value: ViewMode) {
        
        /* set */
        self.viewMode = value
        
        /* done */
        return
    }
}

// NotebookSelectorTableViewController Delegate
extension NoteDetailViewController: NotebookSelectorTableViewControllerDelegate {
    func notebookSelectorTableViewController(_ vc: NotebookSelectorTableViewController, didSelectNotebook notebook: Notebook) {
        print("!!! didSelectNotebook: Entering, notebook=", notebook)
        self.note!.moveToNotebook(notebook)
        print("!!! didSelectNotebook: Done")
    }
}

// MARK: - NoteTableViewControllerDelegate
extension NoteDetailViewController: NoteTableViewControllerDelegate {
    func noteTableViewController(_ vc: NoteTableViewController, didSelectNote note: Note) {
        
        /* set */
        self.notebook   = note.notebook
        self.note       = note
        
        /* check */
        if (vc.splitViewController == nil) {
            vc.navigationController?.pushViewController(self, animated: true)
        }
        else if (vc.splitViewController!.isCollapsed) {
            vc.showDetailViewController(self, sender: vc)
        }
        else {
            
            /* paint */
            paintUIView()
            
            /* check */
            if (vc.splitViewController!.displayMode == .primaryOverlay) {
                vc.splitViewController?.preferredDisplayMode = .primaryHidden
            }
        }
        
        /* done */
        return
    }
}
