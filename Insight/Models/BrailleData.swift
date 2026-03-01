//
//  BrailleData.swift
//  Insight
//
//  Created by Atakan on 4.02.2026.
//

import Foundation

struct BrailleData : Sendable{
    static let shared = BrailleData()
    
    private init() {}
    
    let data: [String: [Int]] = [
        "A": [1],
        "B": [1, 2],
        "C": [1, 4],
        "D": [1, 4, 5],
        "E": [1, 5],
        "F": [1, 2, 4],
        "G": [1, 2, 4, 5],
        "H": [1, 2, 5],
        "I": [2, 4],
        "J": [2, 4, 5],
        "K": [1, 3],
        "L": [1, 2, 3],
        "M": [1, 3, 4],
        "N": [1, 3, 4, 5],
        "O": [1, 3, 5],
        "P": [1, 2, 3, 4],
        "Q": [1, 2, 3, 4, 5],
        "R": [1, 2, 3, 5],
        "S": [2, 3, 4],
        "T": [2, 3, 4, 5],
        "U": [1, 3, 6],
        "V": [1, 2, 3, 6],
        "W": [2, 4, 5, 6],
        "X": [1, 3, 4, 6],
        "Y": [1, 3, 4, 5, 6],
        "Z": [1, 3, 5, 6]
    ]
    
    let allLetters = [
            "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
            "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
        ]
    
    /// Converts 1-based dot indices to a 6-element Bool array (0-based).
    func pattern(_ array: [Int]?) -> [Bool] {
        guard let indices = array else {
            return Array(repeating: false, count: 6)
        }
        var result = Array(repeating: false, count: 6)
        for i in indices {
            if i - 1 >= 0 && i - 1 < 6 {
                result[i - 1] = true
            }
        }
        return result
    }
}
