//
//  UIAlertController+Helpers.swift
//  Everchulo
//
//  Created by ATEmobile on 21/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

// Make Alert Dialog
func makeAlertDialog(title: String?, message: String?, okAction: (title: String, handler: ((UIAlertAction) -> Void)?)) -> UIAlertController {
    let alertDialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    /* add */
    alertDialog.addAction(UIAlertAction(title: okAction.title, style: .default, handler: okAction.handler))
    alertDialog.view.tintColor = Styles.activeColor
    
    /* done */
    return(alertDialog)
}
func showAlertDialog(sender: UIViewController, title: String?, message: String?) -> Void {
    let alertDialog = makeAlertDialog(title: title, message: message, okAction:
        (
            title:      i18NString("es.atenet.app.Accept"),
            handler:    { (action) in sender.dismiss(animated: true) }
        )
    )
    sender.present(alertDialog, animated: true, completion: nil)
}

typealias UIActionSheetMenuItem = (title: String, style: UIAlertActionStyle, hidden: Bool, image: UIImage?, handler: ((UIAlertAction) -> Void)?)

// Make ActionSheet Menu
func makeActionSheetMenu(from source: Any, title: String?, message: String?, items: UIActionSheetMenuItem...) -> UIAlertController {
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
    
    /* check */
    if let popoverController = actionSheetMenu.popoverPresentationController {
        if (type(of: source) == UIView.self) {
            let sourceView = source as! UIView
            popoverController.sourceView = sourceView
            popoverController.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        else if (type(of: source) == UITableView.self) {
            let sourceView = source as! UITableView
            popoverController.sourceView = sourceView
            popoverController.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        else if (type(of: source) == UIBarButtonItem.self) {
            let barButtonItem = source as! UIBarButtonItem
            popoverController.barButtonItem = barButtonItem
        }
        else {
            print("Error: typeOfSource=", type(of: source))
        }
    }

    /* done */
    return(actionSheetMenu)
}

typealias UIPickerActionItem = (title: String, handler: ((UIAlertAction, UIDatePicker) -> Void)?)

// Make ActionSheet DatePicker
func makeActionSheetDatePicker(from source: Any, title: String?, message: String?, doneAction: UIPickerActionItem, cancelAction: UIPickerActionItem, initialValue: Date) -> UIAlertController {
    let actionSheetDatePicker = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    
    /* set */
    let datePicker = UIViewController()
    let uiDatePicker = UIDatePicker()
    uiDatePicker.date = initialValue
    uiDatePicker.timeZone = NSTimeZone.local
    datePicker.view.addSubview(uiDatePicker)
    datePicker.preferredContentSize = CGSize(width: actionSheetDatePicker.view.frame.width,height: actionSheetDatePicker.view.frame.height/3)
    actionSheetDatePicker.setValue(datePicker, forKey: "contentViewController")
    
    /* add */
    actionSheetDatePicker.addAction(UIAlertAction(title: doneAction.title, style: .default, handler: {(action) in doneAction.handler!(action, uiDatePicker) }))
    actionSheetDatePicker.addAction(UIAlertAction(title: cancelAction.title, style: .cancel, handler: {(action) in cancelAction.handler!(action, uiDatePicker) }))
    actionSheetDatePicker.view.tintColor = Styles.activeColor
    
    /* check */
    if let popoverController = actionSheetDatePicker.popoverPresentationController {
        if (type(of: source) == UIView.self) {
            let sourceView = source as! UIView
            popoverController.sourceView = sourceView
            popoverController.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        else if (type(of: source) == UIBarButtonItem.self) {
            let barButtonItem = source as! UIBarButtonItem
            popoverController.barButtonItem = barButtonItem
        }
        else {
            print("Error: typeOfSource=", type(of: source))
        }
    }
    
    /* done */
    return(actionSheetDatePicker)
}

typealias UIConfirmActionItem = (title: String, style: UIAlertActionStyle?, handler: ((UIAlertAction) -> Void)?)

// Make Confirm Dialog
func makeConfirmDialog(title: String?, message: String?, okAction: UIConfirmActionItem, cancelAction: UIConfirmActionItem) -> UIAlertController {
    let confirmDialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    /* add */
    confirmDialog.addAction(UIAlertAction(title: okAction.title, style: okAction.style ?? .default, handler: okAction.handler))
    confirmDialog.addAction(UIAlertAction(title: cancelAction.title, style: cancelAction.style ?? .cancel, handler: cancelAction.handler))
    confirmDialog.view.tintColor = Styles.activeColor
    
    /* done */
    return(confirmDialog)
}


