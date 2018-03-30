//
//  Tag+CoreDataProperties.swift
//  Everchulo
//
//  Created by ATEmobile on 28/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var name: String?

}
