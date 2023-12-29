//
//  RangePair.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/22/23.
//

import Foundation

struct RangePair {
    var masterRange: Range<Int>
    var candidateRange: Range<Int>
    var isMatched: Bool = false

    var description: String {
        return "Master range: \(masterRange), candidate range: \(candidateRange), isMatched = \(isMatched)"
    }

    var masterStartIndex: Int {
        masterRange.startIndex
    }

    var masterEndIndex: Int {
        masterRange.endIndex
    }

    var candidateStartIndex: Int {
        candidateRange.startIndex
    }

    var candidateEndIndex: Int {
        candidateRange.endIndex
    }

    mutating func complete(masterEndIndex: Int, candidateEndIndex: Int, isMatched: Bool) {
        masterRange = masterRange.lowerBound..<masterEndIndex
        candidateRange = candidateRange.lowerBound..<candidateEndIndex
        self.isMatched = isMatched
    }    
}

extension Range<Int> {
    var count: Int {
        endIndex-startIndex
    }
}
