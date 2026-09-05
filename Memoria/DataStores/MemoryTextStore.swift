//
//  MemoryTextStore.swift
//  Memoria
//
//  Created by Joseph McSorley on 8/9/26.
//

import Foundation
import SwiftData

@MainActor
class MemoryTextStore {
    var modelContainer: ModelContainer?
    
    init() {}
    
    var texts: [MemoryText] {
        do {
            let fd = FetchDescriptor<MemoryText>(sortBy: [SortDescriptor(\.displayOrder)])
            guard let texts = try modelContainer?.mainContext.fetch(fd) else { return [] }
            return texts
        } catch {
            print("MemoryTextStore.texts:  Error fetching texts")
        }
        return []
    }

    func add(_ text: MemoryText) {
        modelContainer?.mainContext.insert(text)
        dataStores.save()
    }
    
    func delete(_ textsToDelete: [MemoryText]) {
        textsToDelete.forEach { modelContainer?.mainContext.delete($0) }
        // Update displayOrder values
        var i = 1
        texts.forEach {
            $0.displayOrder = i
            i += 1
        }
        dataStores.save()
    }
}
