//
//  UIAlertController+Helpers.swift
//  Everchulo
//
//  Created by ATEmobile on 21/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

typealias UIAlertActionItem = (title: String, style: UIAlertActionStyle, image: UIImage?, handler: ((UIAlertAction) -> Void)?)

// Make ActionSheet Menu
func makeActionSheetMenu(title: String?, message: String?, items: UIAlertActionItem...) -> UIAlertController {
    let actionSheetMenu = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    
    /* add */
    items.map({ (item: UIAlertActionItem) -> UIAlertAction in
        let action = UIAlertAction(title: item.title, style: item.style, handler: item.handler)
        if (item.image != nil) {
            action.setValue(item.image?.withRenderingMode(.alwaysTemplate), forKey: "image")
            action.setValue(UIColor.darkGray, forKey: "titleTextColor")
        }
        return(action)
    }).forEach {
        actionSheetMenu.addAction($0)
    }
    actionSheetMenu.view.tintColor = Styles.activeColor

    /* done */
    return(actionSheetMenu)
}
