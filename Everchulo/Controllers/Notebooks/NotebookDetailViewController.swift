//
//  NotebookDetailViewController.swift
//  Everchulo
//
//  Created by ATEmobile on 2/4/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

// MARK: - Controller Stuff
class NotebookDetailViewController: UIViewController {
    let notebook: Notebook
    let isModal: Bool
    
    var notebookController: NotebookController?
    
    // MARK: - View Delegate Management
    init(notebook: Notebook, isModal: Bool? = false) {
        self.isModal = isModal!
        self.notebook = notebook
        
        /* set */
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        self.title = i18NString("NotebookDetailViewController.title")
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // View Is Loaded:
    // Setup UIView Layer
    override func viewDidLoad() { super.viewDidLoad()
        
        /* set */
        self.notebookController = NotebookController(vc: self)
        
        /* */
        self.setupUIView()
    }
    
    // View Will Appear:
    //  - Paint UIView
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated)
        
        // Paint UIView
        self.paintUIView()
    }
    
    // MARK: - User Actions
    
    // On Dismiss
    func onDismiss() {
        
        /* focus */
        if (self.nameTextField.isFirstResponder) {
            self.nameTextField.resignFirstResponder()
        }
        
        /* */
        self.presentingViewController?.dismiss(animated: true)
    }
    
    // On Delete Notebook
    func onDeleteNotebook() {
        notebookController!.deleteNotebook(notebook: self.notebook, isModal: self.isModal)
    }
    
    // On Notebook Done
    func onNotebookDone() {
        
        /* focus */
        if (self.nameTextField.isFirstResponder) {
            self.nameTextField.resignFirstResponder()
        }
        
        /* check */
        if (!self.notebook.isActive() && self.activeSwitch.isOn) {
            self.notebook.setActive()
        }
        
        /* set */
        self.notebook.setName(nameTextField.text!)
        self.notebook.save()
        
        /* check */
        if (self.isModal) {
            self.presentingViewController?.dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var infosLabel: UILabel!
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var activeSwitch: UISwitch!
    
    // MARK: - View Stuff
    // Paint UIView
    //  - Map Model Properties with View Data
    //  - Set UIView Data
    func paintUIView() {
        
        /* set */
        self.setUIViewData(NotebookViewData(
            notebookName:   notebook.name,
            isActive:       notebook.isActive()
        ))
    }
    
    // Action Buttons
    var backButtonItem: UIBarButtonItem!
    var closeButtonItem: UIBarButtonItem!
    var okButtonItem: UIBarButtonItem!
}


struct NotebookViewData {
    let notebookName:   String?
    let isActive:       Bool
}
extension NotebookDetailViewController {
    
    // Setup UIView
    func setupUIView() {
        
        /* LABELS */
        self.nameLabel.text     = " \(i18NString("NotebookDetailViewController.nameLabel"))"
        self.activeLabel.text   = i18NString("NotebookDetailViewController.activeLabel")
        
        let activeNotesCount = self.notebook.activeNotes.count
        if (activeNotesCount <= 0) {
            self.infosLabel.text = ""
        }
        else if (activeNotesCount == 1) {
            self.infosLabel.text = "  \(activeNotesCount) \(i18NString("NotebookDetailViewController.infosSingleLabel"))"
        }
        else {
            self.infosLabel.text = "  \(activeNotesCount) \(i18NString("NotebookDetailViewController.infosMultipleLabel"))"
        }
        
        /* CONTROL EVENTS */
        self.nameTextField.addTarget(self, action: #selector(nameTextFieldDidChange), for: UIControlEvents.editingChanged)
        self.activeSwitch.addTarget(self, action: #selector(activeSwitchDidChange), for: .valueChanged)
        
        /* NAVIGATIONBAR */
        self.okButtonItem = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(notebookDoneAction))
        self.navigationItem.rightBarButtonItem = self.okButtonItem
        self.navigationItem.rightBarButtonItem?.tintColor = Styles.activeColor
        
        self.closeButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissAction))
        self.closeButtonItem.tintColor = Styles.activeColor
        self.backButtonItem = UIBarButtonItem(image: UIImage(named: "back-icon")!, style: .done, target: self, action: #selector(notebookDoneAction))
        self.backButtonItem.tintColor = Styles.activeColor
        
        /* check */
        if (self.isModal) {
            self.navigationItem.leftBarButtonItem = self.closeButtonItem
            self.navigationItem.rightBarButtonItem!.setHidden(false)
        }
        else {
            self.navigationItem.leftBarButtonItem = self.backButtonItem
            self.navigationItem.rightBarButtonItem!.setHidden(true)
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        /* check */
        if (self.notebook.isActive()) {
            self.activeLabel.textColor = UIColor.lightGray
            self.activeSwitch.isEnabled = false
        }
        else {
            self.activeLabel.textColor = UIColor.black
            self.activeSwitch.isEnabled = true
        }
    }
    @objc func dismissAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
            self.onDismiss()
        })
    }
    @objc func notebookDoneAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
            self.onNotebookDone()
        })
    }
    @IBAction func deleteAction(_ sender: Any) {
        self.onDeleteNotebook()
    }
    @objc func nameTextFieldDidChange(textField: UITextField) {
        let text = textField.text!
        self.navigationItem.rightBarButtonItem?.isEnabled = ((text.count > 0) && (text != self.notebook.name!))
    }
    @objc func activeSwitchDidChange(switchField: UISwitch) {
        let isOn = switchField.isOn
        self.navigationItem.rightBarButtonItem?.isEnabled = (isOn != self.notebook.isActive())
    }
    
    // Set UIView Data
    //  - Makes UIView Display ViewData
    func setUIViewData(_ data: NotebookViewData) {
        self.nameTextField.text = data.notebookName
        self.activeSwitch.isOn = data.isActive
    }
}
