//
//  ViewController.swift
//  Everchulo
//
//  Created by ATEmobile on 18/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

class EverchuloViewController: UIViewController {
    
    // MARK: - Init
    init() {

        /* */
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        self.view.backgroundColor = UIColor.red
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidAppear(_ animated: Bool) {
        //print(Notebook.create(name: "Primera libreta", commit: true))
        print(Notebook.listAll(returnsObjectsAsFaults: false))
        Notebook.deleteAll()
    }
}

