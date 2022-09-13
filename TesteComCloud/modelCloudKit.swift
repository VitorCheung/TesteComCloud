//
//  modelCloudKit.swift
//  TesteComCloud
//
//  Created by Vitor Cheung on 19/08/22.
//

import Foundation
import CloudKit
import CoreData
import UIKit
import OSLog

enum SharedZone {
    static let name = "SharedZone"
    static let ID = CKRecordZone.ID(
        zoneName: name,
        ownerName: CKCurrentUserDefaultName
    )
}

class modelCloudKit {
    
    let container : CKContainer
    let databasePrivate : CKDatabase
    
    static var shared = modelCloudKit()
    
    init() {
        container = CKContainer(identifier: "iCloud.vitorCheung.TesteComCloud")
        databasePrivate = container.privateCloudDatabase
    }
    
//    func postMorte(_ morte: Int) async throws {
//
//        _ = try await databasePrivate.modifyRecordZones(
//            saving: [CKRecordZone(zoneName: SharedZone.name)],
//            deleting: []
//        )
//        _ = try await databasePrivate.modifyRecords(
//            saving: [MorteANTIGA.asRecord(Morte: morte)],
//            deleting: []
//        )
//    }
//
    
    func postMorte(_ morte: Int) async throws {
        guard let zoneId = try? await getZone() else {
            return
        }
        let recordId = CKRecord.ID(recordName:UUID().description, zoneID:  zoneId)
        let record = CKRecord(recordType: "morte", recordID: recordId)
        record["morte"] = morte as CKRecordValue
        do {
            try await container.sharedCloudDatabase.save(record)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getZone()  async throws -> CKRecordZone.ID?{
        let sharedData = container.sharedCloudDatabase
        let records = try? await sharedData.allRecordZones()
        return records?[0].zoneID
    }
    
    func shareMorteRecords() async throws -> CKShare {
        _ = try await databasePrivate.modifyRecordZones(
            saving: [CKRecordZone(zoneName: SharedZone.name)],
            deleting: []
        )
//        CKShare(
        let share = CKShare(recordZoneID: SharedZone.ID)
        share.publicPermission = .readWrite
        do {
            _ = try await databasePrivate.save(share)
        } catch {
            return try await fetchShare()
        }
        return share
    }
    
    func fetchShare() async throws -> CKShare {
            
        // Use the 'CKRecordNameZoneWideShare' constant to create the record ID.
        let recordID = CKRecord.ID(recordName: CKRecordNameZoneWideShare, zoneID: SharedZone.ID)
            
        // Fetch the share record from the specified record zone.
        do {
            let share = try await databasePrivate.record(for: recordID) as! CKShare
            return share
        } catch let erro {
            print(erro.localizedDescription)
        }
        return try await databasePrivate.record(for: recordID) as! CKShare
            
    }

    
    func accept(_ metadata: CKShare.Metadata) async throws {
        try await container.accept(metadata)
    }
    
    func fetchSharedMorteRecords() async throws -> [MorteANTIGA] {
        let sharedZones = try await container.sharedCloudDatabase.allRecordZones()
        
        return try await withThrowingTaskGroup(of: [MorteANTIGA].self, returning: [MorteANTIGA].self) { group in
            for zone in sharedZones {
                group.addTask {
                    do {
                        return try await self.fetchMorteRecords( in: zone.zoneID, from: self.container.sharedCloudDatabase)
                    } catch {
                        print(error.localizedDescription)
                        return []
                    }
                }
            }
            
            var results: [MorteANTIGA] = []
            for try await history in group { results.append(contentsOf: history) }
            return results
        }
    }
    
    private func fetchMorteRecords(in zone: CKRecordZone.ID? = SharedZone.ID, from database: CKDatabase) async throws -> [MorteANTIGA]{
        let predicate = NSPredicate(format: "999 < morte")
        let query = CKQuery(recordType: "morte", predicate: predicate)
        let response = try await database.records(
            matching: query,
            inZoneWith: zone,
            desiredKeys: nil,
            resultsLimit: CKQueryOperation.maximumResults
        )
        
        return response.matchResults.compactMap { results in
            try? results.1.get()
        }.compactMap { records in
            MorteANTIGA(record: records)
        }
        }
    
}

//    func postMorte(morte:MorteANTIGA) {
//
//
//        self.databasePrivate.save(morte.asRecord()) { savedRecord, error in
//            if error == nil {
//                print("nice")
//            } else {
//                print(error ?? "oi")
//            }
//        }
//    }
    
//    func fetchMorte(){
//        let predicate = NSPredicate(value: true)
//
//        let query = CKQuery(recordType: "morte", predicate: predicate)
//
//        let operation = CKQueryOperation(query: query)
//        operation.database = databasePrivate
//        operation.resultsLimit = 1
//        operation.queuePriority = .veryHigh
//
//        operation.recordMatchedBlock = { recordID, result in
//            switch result {
//            case .success(let record):
//                let M = MorteANTIGA(record: record)
//                self.delegate?.getMorte(dado: M?.MORTE ?? 0)
//            case .failure(let error):
//              print(error)
//          }
//        }
//
//        databasePrivate.add(operation)
//    }
        
//        let matchResult = try await databasePublic.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 1) { result in
//                switch result{
//                case .failure(let error):
//                    print(error)
//                case .success(let (matchResult, _)):
//                    let dado:(CKRecord.ID, Result<CKRecord, Error>)? = matchResult.first
//                    guard let tupla = dado?.1 else { return }
//                    switch tupla{
//                    case .success(let dadoOficial): break
////                        if let morte = Morte.init(record: dadoOficial){
////                            return [morte]
////                        }
//                    case .failure(let error):
//                        throw error
//                    }
//                }
//            }
        
        //    func fetchMorte (_ completion: @escaping (Result<[Morte], Error>) -> Void){
        //        let predicate = NSPredicate(value: true)
        //
        //        let query = CKQuery(recordType: "morte", predicate: predicate)
        //
        //        databasePublic.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 1) { result in
        //            switch result{
        //            case .failure(let error):
        //                completion(.failure(error))
        //            case .success((let matchResult, _)):
        //                let dado:(CKRecord.ID, Result<CKRecord, Error>)? = matchResult.first
        //                guard let tupla = dado?.1 else { return }
        //                switch tupla{
        //                case .success(let dadoOficial):
        //                    if let morte = Morte.init(record: dadoOficial){
        //                        completion(.success([morte]))
        //                    }
        //                case .failure(let error):
        //                    completion(.failure(error))
        //                }
        //            }
        //        }
        
        
        
        
        //        databasePublic.perform(query, inZoneWith: CKRecordZone.default().zoneID){results, errors in
        //
        //
        //            if let error = errors{
        //                DispatchQueue.main.async {
        //                    completion(.failure(error))
        //                }
        //            }
        //
        //            guard let result = results else { return }
        //
        //            let morte = result.compactMap {
        //                Morte.init(record: $0)
        //            }
        //            DispatchQueue.main.async {
        //                completion(.success(morte))
        //            }
        //
        //            }
