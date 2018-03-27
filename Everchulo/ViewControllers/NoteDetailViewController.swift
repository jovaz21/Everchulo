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
    
    // MARK: - Outlets
    @IBOutlet weak var notebookImageView: UIImageView!
    @IBOutlet weak var selectTextButton: UIButton!
    @IBOutlet weak var selectIcon: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextView!
    
    // On Select Notebook
    func onSelectNotebook() { }
    
    // On Note Done
    func onNoteDone() {
        var titleText = self.titleTextField.text
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
            if (self.model.notebook!.notes!.count <= 1) {
                self.model.notebook?.delete()
            }
            self.model.delete()
            
            /* done */
            self.presentingViewController?.dismiss(animated: false)
        }
        
        /* check */
        if (self.model.title == nil) {
            self.model.title = self.model.content
        }
        if (self.model.content == nil) {
            self.model.content = self.model.title
        }
            
        /* save */
        self.model.save()
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
        titleTextField.placeholder = i18NString("NoteDetasilViewController.titlePlaceHolder")
        
        contentTextField.tintColor = Styles.activeColor
        contentTextField.placeholder = i18NString("NoteDetasilViewController.contentPlaceHolder")
        
        /* NAVIGATIONBAR */
        self.okButtonItem = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(noteDoneAction))
        self.okButtonItem.tintColor = Styles.activeColor
        self.navigationItem.leftBarButtonItem = self.okButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor = Styles.activeColor
        //self.navigationItem.rightBarButtonItems = [self.editButtonItem]
    }
    @objc func selectNotebookAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
            self.onSelectNotebook()
        })
    }
    @objc func noteDoneAction() {
            self.onNoteDone()
    }
    
    // Set UIView Data
    //  - Makes UIView Display ViewData
    func setUIViewData(_ data: NoteViewData) {
    }
}
