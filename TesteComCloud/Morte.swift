//
//  Morte.swift
//  TesteComCloud
//
//  Created by Vitor Cheung on 19/08/22.
//

import Foundation
import CloudKit
struct MorteANTIGA:Hashable {
    var MORTE: Int
    let id : CKRecord.ID
    
    init?(record: CKRecord) {
        guard let  MORTE = record["morte"] as? Int else {return nil}
            id = record.recordID
            self.MORTE = MORTE
        }
//    static func asRecord(Morte:Int) -> CKRecord{
//        let record = CKRecord(recordType: "morte", recordID: .init(recordName: SharedZone.name, zoneID: SharedZone.ID))
//        record["morte"] = Morte as CKRecordValue
//        return record
//    }
}
