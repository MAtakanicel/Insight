//
//  WordData.swift
//  Insight
//
//  Created by Atakan on 22.02.2026.
//

import Foundation

struct WordData : Sendable{
    static let shared = WordData()
    
    let threeLetterWords: [String] = [
        "SUN", "CAT", "DOG", "CAR", "SKY", "SEA", "BAT",
        "HAT", "BOX", "CUP", "MAP", "PEN", "DAY", "ICE"
    ]
    
    let fourLetterWords: [String] = [
        "MOON", "BIRD", "TREE", "FISH", "STAR", "FIRE",
        "RAIN", "SNOW", "WIND", "GOLD", "BLUE", "DOOR"
    ]
    
    let fiveLetterWords: [String] = [
        "APPLE", "WATER", "LIGHT", "NIGHT", "EARTH", "OCEAN",
        "MUSIC", "SMILE", "TRAIN", "HOUSE", "HEART", "RIVER"
    ]
    
    var allWords: [String] { return threeLetterWords + fourLetterWords + fiveLetterWords }
        
    func randomWords(_ count: Int) -> [String] {
        Array(allWords.shuffled().prefix(count))
    }
    
}
