//
//  Image+CoreDataProperties.swift
//  Everchulo
//
//  Created by ATEmobile on 31/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var url: String?
    @NSManaged public var note: Note?

}
