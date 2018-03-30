//
//  Note+CoreDataProperties.swift
//  Everchulo
//
//  Created by ATEmobile on 28/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var alarmTimestamp: Double
    @NSManaged public var content: String?
    @NSManaged public var createdTimestamp: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var status: String?
    @NSManaged public var tags: String?
    @NSManaged public var title: String?
    @NSManaged public var updatedTimestamp: Double
    @NSManaged public var images: NSSet?
    @NSManaged public var notebook: Notebook?

}

// MARK: Generated accessors for images
extension Note {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: Image)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: Image)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}
