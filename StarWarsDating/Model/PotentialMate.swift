//
//  PotentialMate.swift
//  StarWarsDating
//
//  Created by Devin Pitcher on 8/1/19.
//  Copyright © 2019 FreshProduce LLC. All rights reserved.
//

import Foundation

// PotentialMatesList is a container for PotentialMates. It's needed when decoding the
// JSON list of persons from the API.

struct PotentialMatesList: Codable {
    var individuals = [PotentialMate]()
}

//  A PotentialMate objects represents a single person pulled the API or loaded from
//  the local database.

struct PotentialMate: Codable {
    
    enum Affiliation: String, Codable {
        
        case none = "none"
        case jedi = "JEDI"
        case resistance = "RESISTANCE"
        case firstOrder = "FIRST_ORDER"
        case sith = "SITH"
    }
    
    var id: Int = -1;
    var firstName: String?
    var lastName: String?
    var birthdate: String?
    var profilePicture: String = ""
    var forceSensitive: Bool = false
    var affiliation: String = "none"
    
    var affilitionVal: Affiliation { return Affiliation(rawValue: affiliation) ?? .none }
    var fullName: String { return "\(firstName ?? "") \(lastName ?? "")"}
    
    var birthdateDate: Date? {
        guard let birthdate = birthdate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: birthdate)
    }
    
    var age: Int {
        guard let bday = birthdateDate else { return 0 }
        let comps = Calendar.current.dateComponents([.year], from: bday, to: Date())
        return comps.year ?? 0
    }
    
    var zodiac: String? {
        guard let bday = birthdateDate else { return nil }
        return bday.zodiac
    }
    
    // exposing CodingKeys so the keys available for use by the PotentialMatesStore
    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case birthdate
        case profilePicture
        case forceSensitive
        case affiliation
    }
    
}
