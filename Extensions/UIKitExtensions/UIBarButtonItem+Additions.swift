//
//  UIBarButtonItem+Additions.swift
//  Everchulo
//
//  Created by ATEmobile on 25/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    // Show / Hide UIBarButtonItem
    func setHidden(_ value: Bool) -> Void {
        if (value) {
            self.isEnabled = false
            self.tintColor = UIColor.clear
        }
        else {
            self.isEnabled = true
            self.tintColor = Styles.activeColor
        }
    }
}

