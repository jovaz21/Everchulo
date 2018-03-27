//
//  NoteDetailViewController.swift
//  Everchulo
//
//  Created by ATEmobile on 27/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

// MARK: - Controller Stuff
class NoteDetailViewController: UIViewController {
    let model: Note
    
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
    
    // MARK: - Outlets for View Stuff
    @IBOutlet weak var notebookImageView: UIImageView!
    @IBOutlet weak var selectTextButton: UIButton!
    @IBOutlet weak var selectIcon: UIImageView!
    
    // Paint UIView
    //  - Map Model Properties with View Data
    //  - Set UIView Data
    func paintUIView() {
        self.setUIViewData(NoteViewData(
            notebookName:   model.notebook?.name,
            title:          model.title,
            content:        model.content
        ))
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
        
        /* NOTEBOOOK SELECTOR */
        notebookImageView.image = UIImage(named: "notebook")!.withRenderingMode(.alwaysTemplate)
        notebookImageView.tintColor = UIColor.gray
        
        selectTextButton.tintColor = Styles.activeColor
        selectTextButton.setTitleColor(Styles.activeColor, for: UIControlState.normal)
        selectTextButton.addTarget(self, action: #selector(onSelectNotebook), for: UIControlEvents.touchUpInside)
        
        selectIcon.image = UIImage(named: "chevron-down")!.withRenderingMode(.alwaysTemplate)
        selectIcon.tintColor = Styles.activeColor
        
        /* NAVIGATIONBAR */
        self.okButtonItem = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(doneAction))
        self.okButtonItem.tintColor = Styles.activeColor
        self.navigationItem.leftBarButtonItem = self.okButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor = Styles.activeColor
        //self.navigationItem.rightBarButtonItems = [self.editButtonItem]
    }
    @objc func onSelectNotebook() {
    }
    @objc func doneAction() {
        
        /* check */
        if (self.model.content == nil) {
            if (self.model.notebook!.notes!.count <= 1) {
                self.model.notebook?.delete()
            }
            self.model.delete()
        }
        
        /* done */
        self.presentingViewController?.dismiss(animated: true) {
            
        }
    }
    
    // Set UIView Data
    //  - Makes UIView Display ViewData
    func setUIViewData(_ data: NoteViewData) {
    }
}
