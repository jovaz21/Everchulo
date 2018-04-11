//
//  String+Localized.swift
//  Everchulo
//
//  Created by ATEmobile on 9/4/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        let lang = Locale.current.regionCode?.lowercased()
        
        /* check */
        guard let path = Bundle.main.path(forResource: lang, ofType: "lproj"), let bundle = Bundle(path: path) else {
            
            // BASE Bundle:
            return(Bundle.main.localizedString(forKey: self, value: "", table: nil))
        }
        
        // LOCALIZED Bundle:
        return(bundle.localizedString(forKey: self, value: "", table: nil))
    }
}
