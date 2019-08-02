//
//  Date+Zodiac.swift
//  StarWarsDating
//
//  Created by Devin Pitcher on 8/2/19.
//  Copyright © 2019 FreshProduce LLC. All rights reserved.
//

import Foundation

extension Date {
    
    var zodiac: String {
        let comps = Calendar.current.dateComponents([.day, .month], from: self)
        guard let month = comps.month, let day = comps.day else { return "Taurus" }
        
        switch month {
        case 1:
            return day >= 21 ? "Aquarius" : "Capricorn"
        case 2:
            return day >= 20 ? "Pisces" : "Aquarius"
        case 3:
            return day >= 21 ? "Aries" : "Pisces"
        case 4:
            return day >= 21 ? "Taurus" : "Aries"
        case 5:
            return day >= 22 ? "Gemini" : "Taurus"
        case 6:
            return day >= 22 ? "Cancer" : "Gemini"
        case 7:
            return day >= 23 ? "Leo" : "Cancer"
        case 8:
            return day >= 23 ? "Virgo" : "Leo"
        case 9:
            return day >= 24 ? "Libra" : "Virgo"
        case 10:
            return day >= 24 ? "Scorpio" : "Libra"
        case 11:
            return day >= 23 ? "Sagittarius" : "Scorpio"
        case 12:
            return day >= 22 ? "Capricorn" : "Sagittarius"
        default:
            return "Taurus"
        }
    }
    
}
