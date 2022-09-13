//
//  Morte+CoreDataProperties.swift
//  TesteComCloud
//
//  Created by Vitor Cheung on 23/08/22.
//
//

import Foundation
import CoreData


extension Morte {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Morte> {
        return NSFetchRequest<Morte>(entityName: "Morte")
    }

    @NSManaged public var morte: Int32

}

extension Morte : Identifiable {

}
