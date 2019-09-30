//
//  Document+CoreDataProperties.swift
//  CoreDataSearch
//
//  Created by Steven Perrin on 9/30/19.
//  Copyright © 2019 Steven Perrin. All rights reserved.
//
//

import Foundation
import CoreData


extension Document {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

    @NSManaged public var name: String?
    @NSManaged public var content: String?
    @NSManaged public var rawModifiedDate: Date?
    @NSManaged public var size: Int64

}
