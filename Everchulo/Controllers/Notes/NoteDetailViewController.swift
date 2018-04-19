//
//  NoteDetailViewController.swift
//  Everchulo
//
//  Created by ATEmobile on 27/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import AVFoundation
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
    
    var noteController: NoteController?
    
    var imageViewControllers: [ImageViewController] = [ImageViewController]()
    
    // Delegate
    weak var delegate: NoteDetailViewControllerDelegate?
    
    // MARK: - Init
    init(notebook: Notebook? = nil, note: Note? = nil, viewMode: ViewMode? = nil) {
        self.notebook = notebook
        self.note = note
        
        /* check */
        if (viewMode != nil) {
            self.viewMode = viewMode!
        }
        
        /* set */
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        self.title = ""
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // View Is Loaded:
    // Setup UIView Layer
    override func viewDidLoad() { super.viewDidLoad()
        
        /* set */
        self.noteController = NoteController(vc: self)
        
        /* */
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
        if ((self.note == nil) && (self.viewMode != .empty)) {
            
            /* New Note */
            self.setViewMode(.new)
            
            /* create */
            self.note = Note.create(notebook!)!
        }
        
        /* check */
        if ((self.note != nil) && (self.viewMode == .empty)) {
            self.setViewMode(.edit)
        }
        
        // Paint UIView
        if (self.note != nil) {
            self.paintUIView()
        }
    }
    /*
    override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated)
        self.paintUIView()
    }*/
    
    // MARK: - Outlets
    @IBOutlet weak var notebookImageView: UIImageView!
    @IBOutlet weak var selectTextButton: UIButton!
    @IBOutlet weak var selectIcon: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextView!
    
    // MARK: - User Actions
    
    // On Select Notebook
    func onSelectNotebook() {
        
        /* set */
        let notebookSelectorVC = NotebookSelectorTableViewController(notebook: self.note!.notebook!)
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
        var isContentUpdated = false
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
        if ((titleText!.count > 0) && (titleText! != self.note!.title)) {
            self.note!.title = titleText
            isContentUpdated = true
        }
        if ((contentText!.count > 0) && (contentText! != self.note!.content)) {
            self.note!.content = contentText
            isContentUpdated = true
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
            isContentUpdated = true
        }
        if (self.note!.content == nil) {
            self.note!.content = self.note!.title
            isContentUpdated = true
        }
        
        /* check */
        if ((self.viewMode == .edit) && isContentUpdated) {
            self.note!.updatedTimestamp = Date().timeIntervalSince1970
        }
            
        /* save */
        if (self.delegate != nil) { // Delegate
            if (self.viewMode == .new) {
                self.delegate!.noteDetailViewController(self, willCreateNote: self.note!)
            }
        }
        if (!self.note!.isActive()) {
            print("!!!<NoteDetailViewController> onNoteDone: Setting New Note ACTIVE, notebookActiveNotesCount=", self.note!.notebook!.activeNotes.count)
            self.note!.setActive()
        }
        if (((self.viewMode == .new) || (self.notebook != self.note!.notebook!)) && !self.note!.notebook!.isActive()) {
            print("!!!<NoteDetailViewController> onNoteDone: Setting Notebook ACTIVE, notebookActiveNotesCount=", self.note!.notebook!.activeNotes.count)
            self.note!.notebook!.setActive()
        }
        print("!!!<NoteDetailViewController> onNoteDone: Saving Data, notebookActiveNotesCount=", self.note!.notebook!.activeNotes.count)
        self.note!.save()
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
        
        // Release UIView
        self.releaseUIView()

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
        var alarmDate: Date? = Date(timeIntervalSince1970: note!.alarmTimestamp)
        
        /* check */
        if (note!.alarmTimestamp <= 0) {
            alarmDate = nil
        }
        
        /* set */
        self.setUIViewData(NoteViewData(
            notebookName:   note!.notebook?.name,
            title:          note!.title,
            content:        note!.content,
            alarmDate:      alarmDate
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
    
    // MARK: - Action Buttons
    var okButtonItem: UIBarButtonItem!
    var backButtonItem: UIBarButtonItem!
    var alarmButtonItem: UIBarButtonItem!
    var infosButtonItem: UIBarButtonItem!
    var menuBarButtonItem: UIBarButtonItem!
    var cameraButtonItem: UIBarButtonItem!
}

// MARK: - View Stuff
struct NoteViewData {
    let notebookName:   String?
    let title:          String?
    let content:        String?
    let alarmDate:      Date?
}
extension NoteDetailViewController {
    
    // View Mode
    enum ViewMode: String {
        case new
        case empty
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
        titleTextField.addTarget(self, action: #selector(titleTextFieldDidEnd), for: UIControlEvents.editingDidEnd)
        
        contentTextField.tintColor = Styles.activeColor
        if (self.viewMode == .new) {
            contentTextField.placeholder = i18NString("NoteDetailsViewController.contentPlaceHolder")
        }
        contentTextField.delegate = self
        
        /* NAVIGATIONBAR */
        self.navigationController?.navigationBar.tintColor = Styles.activeColor
        
        self.okButtonItem = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(noteDoneAction))
        self.okButtonItem.tintColor = Styles.activeColor
        self.backButtonItem = UIBarButtonItem(image: UIImage(named: "back-icon")!, style: .done, target: self, action: #selector(noteDoneAction))
        self.backButtonItem.tintColor = Styles.activeColor
        if (self.viewMode == .new) {
            self.navigationItem.leftBarButtonItem = self.okButtonItem
        }
        else {
            self.navigationItem.leftBarButtonItem = self.backButtonItem
        }
        
        self.alarmButtonItem = UIBarButtonItem(image: UIImage(named: "alarm")!, style: .done, target: self, action: #selector(displayAlarmMenuAction))
        self.alarmButtonItem.tintColor = Styles.activeColor
        self.infosButtonItem = UIBarButtonItem(image: UIImage(named: "information-outline")!, style: .done, target: self, action: #selector(displayInfosAction))
        self.infosButtonItem.tintColor = Styles.activeColor
        self.navigationItem.rightBarButtonItems = [self.infosButtonItem, self.alarmButtonItem]
        
        /* TOOLBAR */
        navigationController?.toolbar.isHidden  = false
        navigationController?.isToolbarHidden   = false
        self.menuBarButtonItem = UIBarButtonItem(image: UIImage(named: "dots-horizontal")!, style: .done, target: self, action: #selector(displayNoteMenuAction))
        self.menuBarButtonItem.tintColor = Styles.activeColor
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.cameraButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(displayImageMenuAction))
        self.cameraButtonItem.tintColor = Styles.activeColor
        self.setToolbarItems([self.menuBarButtonItem, flexibleSpace, self.cameraButtonItem], animated: false)
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
    @objc func titleTextFieldDidEnd(textField: UITextField) {
        if ((textField.text!.count > 0) && (textField.text! != self.note!.title)) {
            self.note!.title = textField.text!
            self.note!.updatedTimestamp = Date().timeIntervalSince1970
        }
    }
    func contentTextFieldDidEnd(_ textView: UITextView) {
        if ((textView.text!.count > 0) && (textView.text! != self.note!.content)) {
            self.note!.content = textView.text!
            self.note!.updatedTimestamp = Date().timeIntervalSince1970
        }
    }
    
    //
    func wrappedInNavigationWithToolbarInitialized() -> UINavigationController {
        let navController = UINavigationController(rootViewController: self)
        
        /* TOOLBAR */
        navigationController?.toolbar.isHidden  = false
        navigationController?.isToolbarHidden   = false
        self.menuBarButtonItem = UIBarButtonItem(image: UIImage(named: "dots-horizontal")!, style: .done, target: self, action: #selector(displayNoteMenuAction))
        self.menuBarButtonItem.tintColor = Styles.activeColor
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.cameraButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(displayImageMenuAction))
        self.cameraButtonItem.tintColor = Styles.activeColor
        self.setToolbarItems([self.menuBarButtonItem, flexibleSpace, self.cameraButtonItem], animated: false)
        
        /* done */
        return(navController)
    }
    
    // Release UIView
    func releaseUIView() {
        self.releaseImageViews()
    }
    
    // Set UIView Data
    //  - Makes UIView Display ViewData
    func setUIViewData(_ data: NoteViewData) {
        
        /* */
        print("!!! setUIViewData: Entering, data=", data)
        
        /* alarm */
        self.alarmButtonItem.setHidden(data.alarmDate == nil)
        
        /* set */
        self.selectTextButton.setTitle(data.notebookName, for: .normal)
        if (data.title != nil) {
            self.titleTextField.text = data.title
        }
        if (data.content != nil) {
            self.contentTextField.text = data.content
        }
        
        /* ImageViews */
        self.paintImageViews(data)
        
        /* */
        print("!!! setUIViewData: Done")
        return
    }
    
    // MARK: - Instance Methods
    func setViewMode(_ value: ViewMode) {
        
        /* set */
        self.viewMode = value
        
        /* */
        self.setupUIView()
        
        /* check */
        if (self.viewMode == .new) {
            self.navigationItem.leftBarButtonItem = self.okButtonItem
            self.menuBarButtonItem.setHidden(true)
        }
        else {
            self.navigationItem.leftBarButtonItem = self.backButtonItem
            self.menuBarButtonItem.setHidden(false)
        }
        
        /* done */
        return
    }
}

// NotebookSelectorTableViewController Delegate
extension NoteDetailViewController: NotebookSelectorTableViewControllerDelegate {
    func notebookSelectorTableViewController(_ vc: NotebookSelectorTableViewController, didCancel notebook: Notebook, presentingViewController: UIViewController) {
    }
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
            return
        }
        
        /* */
        print("!!!!SplitViewController: isCollapsed: ", vc.splitViewController!.isCollapsed)
        switch (vc.splitViewController!.displayMode) {
        case .allVisible:
            print("!!!!All Visible")
        case .primaryHidden:
            print("!!!!Primary Hidden")
        case .primaryOverlay:
            print("!!!!Primary Overlay")
        case .automatic:
            print("!!!!Automatic")
        }
        
        /* check */
        if (vc.splitViewController!.isCollapsed) {
            vc.navigationController?.pushViewController(self, animated: true)
            return
        }
        
        /* check */
        if ((self.navigationController == nil) || self.splitViewController!.viewControllers.index(of: self.navigationController!) == nil) {
            vc.splitViewController!.viewControllers.append(self.wrappedInNavigation())
        }
        
        /* Paint */
        self.paintUIView()

        /* check */
        if (vc.splitViewController!.displayMode == .primaryOverlay) {
            vc.splitViewController?.preferredDisplayMode = .primaryHidden
        }
        
        /* done */
        return
    }
}

// MARK: - UITextViewDelegate
extension NoteDetailViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        self.contentTextFieldDidEnd(textView)
    }
}
