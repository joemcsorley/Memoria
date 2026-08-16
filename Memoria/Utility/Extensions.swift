//
//  Untitled.swift
//  Memoria
//
//  Created by Joseph McSorley on 8/9/26.
//

extension Collection {
    subscript(safe index: Index?) -> Element? {
        guard let index, indices.contains(index) else { return nil }
        return self[index]
    }
}

extension Array {
    mutating func resize(to newCount: Int, using filler: Element) {
        if newCount <= count {
            removeLast(count - newCount)
        } else {
            for _ in count..<newCount { append(filler) }
        }
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
