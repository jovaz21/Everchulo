//
//  UIViewController+Additions.swift
//  Everchulo
//
//  Created by ATEmobile on 18/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

extension UIViewController {
    func wrappedInNavigation() -> UINavigationController {
        return(UINavigationController(rootViewController: self))
    }
}
