//
//  ViewController.swift
//  Everchulo
//
//  Created by ATEmobile on 18/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

// Everchulo ViewController
class EverchuloViewController: NoteTableViewController {
    
    // MARK: - Properties
    let detailVCItem: NoteDetailViewController
    
    // MARK: - Init
    override init() {
        
        /* set */
        self.detailVCItem = NoteDetailViewController()
        
        /* */
        super.init()
        self.delegate = self.detailVCItem
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - UISplitViewControllerDelegate:
// Makes App Working Fine on any iPhone/iPad (Universal)... When UITabBarController is set as the master view controller, the default behaviour on iPhone 4, 5, 6, etc (compact) upon a cell selection is, instead of getting a push transition, to get a modal transition
extension EverchuloViewController: UISplitViewControllerDelegate {
    
    // Show Detail:
    // When SplitView is Collapsed and 'showDetail' is Invoked upon a Cell Selection, then PUSH DetailVC into the Navigation Stack of the ListVC's NavigationController
    func splitViewController(_ splitViewController: UISplitViewController,
                             showDetail vc: UIViewController,
                             sender: Any?) -> Bool {
        
        /* check */
        if (!splitViewController.isCollapsed) { // If Not Collapsed, Okay, Use Default Behaviour...
            return(false)
        }
        if (!(sender is UITableViewController)) { // If Not Invoked upon Cell Selection, Okay...
            return(false)
        }
        
        /* */
        let detailVC    = vc
        let listVC      = sender as! UITableViewController
        
        /* push */
        listVC.navigationController?.pushViewController(detailVC, animated: true)
        return(true)
    }
    
    // Separate Secondary from Primary:
    // When Back from 'Compact' to 'Regular' Horizontal Width (i.e. iPhone 8 Plus portrait => landscape), then POP DetailVC from the Navigation Stack of the ListVC's NavigationController (if needed) and return it (Wrapped in a New NavigationController) to the SplitViewController
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        let listVC      = self
        let detailVC    = self.detailVCItem
        
        /* check */
        if (listVC.navigationController?.topViewController == detailVC) {
            listVC.navigationController?.popViewController(animated: false)
        }
        
        /* done */
        return(detailVC.wrappedInNavigation())
    }
    
    // Hide/Show DisplayButtonItem According to Current Display Mode
    private func splitViewController(_ svc: UISplitViewController, didChangeTo displayMode: UISplitViewControllerDisplayMode) { self.setupDisplayModeButton(svc) }
    func setupDisplayModeButton(_ svc: UISplitViewController) {
        
        /* check */
        if (svc.isCollapsed) {
            return
        }
        
        /* check */
        if (svc.displayMode == .allVisible) {
            self.detailVCItem.navigationItem.leftBarButtonItem = nil
        }
        else {
            self.detailVCItem.navigationItem.leftBarButtonItem = svc.displayModeButtonItem
        }
    }
}
