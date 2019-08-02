//
//  PotentialMatesStore.swift
//  StarWarsDating
//
//  Created by Devin Pitcher on 8/1/19.
//  Copyright © 2019 FreshProduce LLC. All rights reserved.
//
//  The PotentialMatesStore is a singleton class that handles both downloading content
//  from the API and storing and retrieving from the local database.

import Foundation
import Alamofire
import SQLite

class PotentialMatesStore {
    
    static let potoentialMatesRefreshedNotif = Notification.Name("potential-mates-refreshed")
    
    // Singleton
    static let sharedInstance = PotentialMatesStore()
    
    // db connection
    private var db: Connection?
    
    // db schema consts
    private let matesTable = Table("mates")
    private let idColumn = Expression<Int>(PotentialMate.CodingKeys.id.rawValue)
    private let firstNameColumn = Expression<String?>(PotentialMate.CodingKeys.firstName.rawValue)
    private let lastNameColumn = Expression<String?>(PotentialMate.CodingKeys.lastName.rawValue)
    private let birthDateColumn = Expression<String?>(PotentialMate.CodingKeys.birthdate.rawValue)
    private let profPicURLColumn = Expression<String>(PotentialMate.CodingKeys.profilePicture.rawValue)
    private let hasForceColumn = Expression<Bool>(PotentialMate.CodingKeys.forceSensitive.rawValue)
    private let affiliationColumn = Expression<String>(PotentialMate.CodingKeys.affiliation.rawValue)
    
    // api url
    let getMatesURL = "https://edge.ldscdn.org/mobile/interview/directory"
        
    private init() {
        
        // open db - stored in cache dir so that we don't include downloadable data in iCloud backup
        let cachePathURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dbPathURL = cachePathURL.appendingPathComponent("starwarsdb.sqlite3")
        do {
            db = try Connection(dbPathURL.absoluteString)
            
            // add table if it doesn't exist
            // TODO: migrate schema if API changes
            try db?.run(matesTable.create(ifNotExists: true) { t in
                t.column(idColumn, primaryKey: true)
                t.column(firstNameColumn)
                t.column(lastNameColumn)
                t.column(birthDateColumn)
                t.column(profPicURLColumn)
                t.column(hasForceColumn)
                t.column(affiliationColumn)
            })
        
            refreshMates()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func test() {
        print("test")
    }
    
    // insert (or replace) mate in db
    func addOrReplaceMate(mate: PotentialMate) {
        guard let db = db else { return }
        
        do {
            // insert or update row
            // note - the insert with "replace" option isn't available when inserting a Codable
            let count = try db.scalar(matesTable.filter(idColumn == mate.id).count)
            if count == 0 {
                try db.run(matesTable.insert(mate))
            } else {
                try db.run(matesTable.filter(idColumn == mate.id).update(mate))
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    // get a mate from db
    func getMate(for id: Int) -> PotentialMate? {
        guard let db = db else { return nil }
        
        do {
            // get first (and only) row
            // SELECT * FROM mates WHERE id == <id>
            if let mateRow = try db.prepare(matesTable.filter(idColumn == id)).first(where: { _ in return true }) {
                let mate: PotentialMate = try mateRow.decode()
                return mate
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }

    // get array of all mates from db
    func getAllMates() -> [PotentialMate] {
        guard let db = db else { return [] }

        do {
            // SELECT * FROM mates
            let mates: [PotentialMate] = try db.prepare(matesTable).map { row in
                return try row.decode()
            }
            return mates
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
    
    // fetch mates from API
    func refreshMates() {
        
        // there's an internet connection
        guard NetworkReachabilityManager()?.isReachable == true || getRowCount() > 0 else {
            // TODO: alert user that they need an internet connection
            print("no internet connection")
            return
        }
        
        Alamofire.request(getMatesURL).responseJSON { [weak self] response in
            guard response.result.isSuccess, let jsonData = response.data else {
                if self?.getRowCount() == 0 {
                    // TODO: alert user that we're unable to contact the server
                }
                print("error while fetching potential mates from API: \(response.result.error?.localizedDescription ?? "unknown error")")
                return
            }
            
            // decode response and load into db
            let decoder = JSONDecoder()
            do {
                let mates = try decoder.decode(PotentialMatesList.self, from: jsonData)
                for mate in mates.individuals {
                    self?.addOrReplaceMate(mate: mate)
                }
                // NOTE - this does not handle the case where individuals were deleted on the backend. I'm assuming
                //        there'd be other another endpoint/push/etc. to notify the app of deletions
                
                // notify observers of refresh
                NotificationCenter.default.post(name: PotentialMatesStore.potoentialMatesRefreshedNotif, object: self)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func getRowCount() -> Int {
        guard let db = db else { return 0 }
        return (try? db.scalar(matesTable.count)) ?? 0
    }
}
