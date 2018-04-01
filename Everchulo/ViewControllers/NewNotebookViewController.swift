//
//  NewNotebookViewController.swift
//  Everchulo
//
//  Created by ATEmobile on 1/4/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

// MARK: - Controller Stuff
class NewNotebookViewController: UIViewController {
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        self.title = i18NString("NewNotebookViewController.title")
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
    @IBOutlet weak var nameTextField: UITextField!
    
    // On New Notebook Done
    func onNewNotebookDone() {
        
        /* done */
        self.presentingViewController?.dismiss(animated: true)
    }
    
    // Paint UIView
    //  - Map Model Properties with View Data
    //  - Set UIView Data
    func paintUIView() {
        
        /* focus */
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
            self.nameTextField.becomeFirstResponder()
        })
    }
    
    // Action Buttons
    var cancelButtonItem: UIBarButtonItem!
    var okButtonItem: UIBarButtonItem!
}

// MARK: - View Stuff
extension NewNotebookViewController {
    
    // Setup UIView
    func setupUIView() {
        
        // TEXT FIELD
        nameTextField.tintColor = Styles.activeColor
        
        /* NAVIGATIONBAR */
        self.cancelButtonItem = UIBarButtonItem(title: i18NString("es.atenet.app.Cancel"), style: .done, target: self, action: #selector(cancelAction))
        self.navigationItem.leftBarButtonItem = self.cancelButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor = Styles.activeColor
        
        self.okButtonItem = UIBarButtonItem(title: i18NString("es.atenet.app.Create"), style: .done, target: self, action: #selector(newNotebookDoneAction))
        self.navigationItem.rightBarButtonItem = self.okButtonItem
        self.navigationItem.rightBarButtonItem?.tintColor = Styles.activeColor
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    @objc func newNotebookDoneAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
            self.onNewNotebookDone()
        })
    }
    @objc func cancelAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
            self.presentingViewController?.dismiss(animated: true)
        })
    }
    
    // MARK: - Instance Methods
}
