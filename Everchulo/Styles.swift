//
//  Styles.swift
//  Everchulo
//
//  Created by ATEmobile on 22/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

final class Styles {
    static let whiteBackgroundGradientLayerForView = { (view: UIView) -> CAGradientLayer in
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.white.cgColor, UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.1).cgColor]
       return(gradient)
    }
    static let activeColor = UIColor(red: 34.0/255.0, green: 177.0/255.0, blue: 76.0/255.0, alpha: 1)
}
