//
//  UIAlertController+Helpers.swift
//  Everchulo
//
//  Created by ATEmobile on 21/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

typealias UIActionSheetMenuItem = (title: String, style: UIAlertActionStyle, hidden: Bool, image: UIImage?, handler: ((UIAlertAction) -> Void)?)

// Make ActionSheet Menu
func makeActionSheetMenu(title: String?, message: String?, items: UIActionSheetMenuItem...) -> UIAlertController {
    let actionSheetMenu = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    
    /* add */
    items.map({ (item: UIActionSheetMenuItem) -> UIAlertAction? in
        
        /* check */
        if (item.hidden) {
            return(nil)
        }
        
        /* set */
        let action = UIAlertAction(title: item.title, style: item.style, handler: item.handler)
        if (item.image != nil) {
            action.setValue(item.image?.withRenderingMode(.alwaysTemplate), forKey: "image")
            action.setValue(UIColor.darkGray, forKey: "titleTextColor")
        }
        return(action)
    }).forEach {
        guard let action = $0 else { return }
        actionSheetMenu.addAction(action)
    }
    actionSheetMenu.view.tintColor = Styles.activeColor

    /* done */
    return(actionSheetMenu)
}

typealias UIConfirmActionItem = (title: String, style: UIAlertActionStyle?, handler: ((UIAlertAction) -> Void)?)

// Make Confirm Dialog
func makeConfirmDialog(title: String?, message: String?, okAction: UIConfirmActionItem, cancelAction: UIConfirmActionItem) -> UIAlertController {
    let confirmDialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    /* add */
    confirmDialog.addAction(UIAlertAction(title: okAction.title, style: okAction.style ?? .default, handler: okAction.handler))
    //ok.setValue(Styles.activeColor, forKey: "titleTextColor")
    confirmDialog.addAction(UIAlertAction(title: cancelAction.title, style: cancelAction.style ?? .cancel, handler: cancelAction.handler))
    //cancel.setValue(Styles.activeColor, forKey: "titleTextColor")
    confirmDialog.view.tintColor = Styles.activeColor
    
    /* done */
    return(confirmDialog)
}
