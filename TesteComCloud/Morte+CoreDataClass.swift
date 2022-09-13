//
//  Morte+CoreDataClass.swift
//  TesteComCloud
//
//  Created by Vitor Cheung on 23/08/22.
//
//

import Foundation
import CoreData
import CloudKit
import UIKit

@objc(Morte)
public class Morte: NSManagedObject {
    init?(record: CKRecord) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Morte", in: context) else { return nil}
        super.init(entity: entity, insertInto: context)
        guard let  MORTE = record["morte"] as? Int else {return nil}
        morte = Int32(MORTE)
        }
}
