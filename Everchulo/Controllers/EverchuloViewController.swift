//
//  ViewController.swift
//  Everchulo
//
//  Created by ATEmobile on 18/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

// Everchulo ViewController
class EverchuloViewController: UISplitViewController {
    
    // MARK: - Properties
    let listVCItem: NoteTableViewController
    let detailVCItem: NoteDetailViewController
    
    // MARK: - Init
    init() {
        
        /* set */
        self.listVCItem = NoteTableViewController()
        self.detailVCItem = NoteDetailViewController(viewMode: .empty)
        self.listVCItem.delegate = self.detailVCItem
        
        /* */
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        
        /* set */
        self.viewControllers = [self.listVCItem.wrappedInNavigation(), self.detailVCItem.wrappedInNavigation()]
        
        /* set */
        self.delegate = self
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // View Did Appear:
    // - Add Device Orientation Observer
    // - If no Note is selected, make Primary View overlays and remove Detail View
    override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated)
        
        // Add Observer
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        /* check */
        if (self.detailVCItem.note != nil) {
            return
        }
        
        /* */
        print("!!!! isCollapsed=", self.isCollapsed)
        print("!!!! isLandscape=", UIDevice.current.orientation.isLandscape)
        switch (displayMode) {
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
        if (!self.isCollapsed && (self.displayMode == .allVisible)) {
            if (UIDevice.current.orientation.isLandscape || (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad)) { // iPhone8 - Landscape || iPAD
                guard let detailVCItemNC = self.detailVCItem.navigationController,
                    let detailVCItemNCIndex = self.viewControllers.index(of: detailVCItemNC) else {
                        return
                }
                self.viewControllers.remove(at: detailVCItemNCIndex)
            }
        }
        else if (self.displayMode == .primaryHidden) { // iPAD - Portrait
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.500, execute: {
                self.preferredDisplayMode = .primaryOverlay
            })
            guard let detailVCItemNC = self.detailVCItem.navigationController,
                let detailVCItemNCIndex = self.viewControllers.index(of: detailVCItemNC) else {
                    return
            }
            self.viewControllers.remove(at: detailVCItemNCIndex)
        }
        
        /* done */
        return
    }
    @objc func deviceOrientationDidChange(notification: Notification) {
        
        /* */
        print("!!!!Orientation Changed, isLandscape=", UIDevice.current.orientation.isLandscape)
        print("!!!! isCollapsed=", self.isCollapsed)
        switch (displayMode) {
        case .allVisible:
            print("!!!!All Visible")
        case .primaryHidden:
            print("!!!!Primary Hidden")
        case .primaryOverlay:
            print("!!!!Primary Overlay")
        case .automatic:
            print("!!!!Automatic")
        }
        
        /* TableView Not Correctly Refreshed on Orientation Updates */
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.250, execute: {
            self.listVCItem.reloadTableViewData()
        })
        
        /* check */
        if (self.detailVCItem.note != nil) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) { // iPAD
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.500, execute: {
                    if (UIDevice.current.orientation.isLandscape) {
                        self.preferredDisplayMode = .automatic
                    }
                    else {
                        self.preferredDisplayMode = .primaryOverlay
                    }
                })
            }
            return
        }
        
        /* check */
        if (self.isCollapsed && (displayMode == .allVisible)) {
            if (UIDevice.current.orientation.isLandscape) { // iPhone8 - Landscape
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.500, execute: {
                    self.preferredDisplayMode = .primaryOverlay
                })
                guard let detailVCItemNC = self.detailVCItem.navigationController,
                    let detailVCItemNCIndex = self.viewControllers.index(of: detailVCItemNC) else {
                        return
                }
                self.viewControllers.remove(at: detailVCItemNCIndex)
            }
        }
        else if (!self.isCollapsed && (displayMode == .allVisible)) {
            if ((UIDevice.current.orientation.isLandscape) || (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad)) { // iPhone8 - Landscape / iPAD
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.500, execute: {
                    self.preferredDisplayMode = .primaryOverlay
                })
                guard let detailVCItemNC = self.detailVCItem.navigationController,
                    let detailVCItemNCIndex = self.viewControllers.index(of: detailVCItemNC) else {
                        return
                }
                self.viewControllers.remove(at: detailVCItemNCIndex)
            }
        }
        else if (displayMode == .primaryHidden) { // iPAD - Portrait
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.500, execute: {
                self.preferredDisplayMode = .primaryOverlay
            })
        }
        else if (displayMode == .primaryOverlay) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.500, execute: {
                self.preferredDisplayMode = .primaryOverlay
            })
        }
    }
    
    // View Will Disappear:
    override func viewWillDisappear(_ animated: Bool) { super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UISplitViewControllerDelegate:
// Makes App Working Fine on any iPhone/iPad (Universal)... When UITabBarController is set as the master view controller, the default behaviour on iPhone 4, 5, 6, etc (compact) upon a cell selection is, instead of getting a push transition, to get a modal transition
extension EverchuloViewController: UISplitViewControllerDelegate {
    
    // Collapse Secondary:
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return(true)
    }
    
    // Separate Secondary from Primary:
    // When Back from 'Compact' to 'Regular' Horizontal Width (i.e. iPhone 8 Plus portrait => landscape), then POP DetailVC from the Navigation Stack of the ListVC's NavigationController (if needed) and return it (Wrapped in a New NavigationController) to the SplitViewController
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        let listVC      = self.listVCItem
        let detailVC    = self.detailVCItem
        
        /* check */
        if (listVC.navigationController?.topViewController == detailVC) {
            listVC.navigationController?.popViewController(animated: false)
        }
        
        /* check */
        if (self.detailVCItem.note == nil) {
            return(nil)
        }
        
        /* done */
        return(detailVC.wrappedInNavigationWithToolbarInitialized())
    }
}
