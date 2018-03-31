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
    let model: Note
    
    // Delegate
    weak var delegate: NoteDetailViewControllerDelegate?
    
    // MARK: - Init
    init(model: Note) {
        
        /* set */
        self.model = model
        
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
        let notebookSelectorVC = NotebookSelectorTableViewController(model: self.model)
        notebookSelectorVC.delegate = self
        
        /* show */
        self.present(notebookSelectorVC.wrappedInNavigation(), animated: true)
    }
    
    // On Note Done
    func onNoteDone() {
        let titleText = self.titleTextField.text
        let contentText = self.contentTextField.text
        
        /* check */
        if (titleText!.count > 0) {
            self.model.title = titleText
        }
        if (contentText!.count > 0) {
            self.model.content = contentText
        }
        
        /* check */
        if ((self.model.title == nil) && (self.model.content == nil)) {
            
            /* delete */
            self.model.delete()
            
            /* done */
            self.presentingViewController?.dismiss(animated: false)
            return
        }
        
        /* check */
        if (self.model.title == nil) {
            self.model.title = self.model.content
        }
        if (self.model.content == nil) {
            self.model.content = self.model.title
        }
            
        /* save */
        print("!!!<NoteDetailViewController> onNoteDone: Setting New Note ACTIVE, notebookActiveNotesCount=", self.model.notebook!.activeNotes.count)
        if (self.delegate != nil) { // Delegate
            self.delegate!.noteDetailViewController(self, willCreateNote: self.model)
        }
        self.model.notebook!.setActive()
        self.model.notebook!.save()
        self.model.setActive()
        print("!!!<NoteDetailViewController> onNoteDone: Saving Data, notebookActiveNotesCount=", self.model.notebook!.activeNotes.count)
        self.model.save()
        print("!!!<NoteDetailViewController> onNoteDone: New Note Added, notebookActiveNotesCount=", self.model.notebook!.activeNotes.count)
        if (self.delegate != nil) { // Delegate
            self.delegate!.noteDetailViewController(self, didCreateNote: self.model)
        }

        /* done */
        self.presentingViewController?.dismiss(animated: false)
    }

    // Paint UIView
    //  - Map Model Properties with View Data
    //  - Set UIView Data
    func paintUIView() {
        
        /* set */
        self.setUIViewData(NoteViewData(
            notebookName:   model.notebook?.name,
            title:          model.title,
            content:        model.content
        ))
        
        /* focus */
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
            self.contentTextField.becomeFirstResponder()
        })
        
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
        contentTextField.placeholder = i18NString("NoteDetailsViewController.contentPlaceHolder")
        
        /* NAVIGATIONBAR */
        self.okButtonItem = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(noteDoneAction))
        self.okButtonItem.tintColor = Styles.activeColor
        self.navigationItem.leftBarButtonItem = self.okButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor = Styles.activeColor
        
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
}

// NotebookSelectorTableViewController Delegate
extension NoteDetailViewController: NotebookSelectorTableViewControllerDelegate {
    func notebookSelectorTableViewController(_ vc: NotebookSelectorTableViewController, didSelectNotebook notebook: Notebook) {
        print("!!! didSelectNotebook: Entering, notebook=", notebook)
        //self.model.notebook?.removeFromNotes(self.model)
        self.model.moveToNotebook(notebook)
        print("!!! didSelectNotebook: Done")
    }
}
