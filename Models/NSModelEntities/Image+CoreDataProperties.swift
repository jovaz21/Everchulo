//
//  Image+CoreDataProperties.swift
//  Everchulo
//
//  Created by ATEmobile on 11/4/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var data: NSData?
    @NSManaged public var heightRatio: Float
    @NSManaged public var leftRatio: Float
    @NSManaged public var topRatio: Float
    @NSManaged public var frontIndex: Int64
    @NSManaged public var note: Note?

}
