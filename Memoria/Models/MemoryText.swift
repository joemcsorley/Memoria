//
//  MemoryText.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/28/23.
//

import Foundation
import SwiftData

@Model
final class MemoryText: Hashable, Sendable, CustomStringConvertible {
    var dateAdded: Date
    var displayOrder = 0
    var title: String
    @Attribute(.externalStorage) var text: String
    
    init(title: String, text: String, dateAdded: Date = Date()) {
        self.dateAdded = dateAdded
        self.title = title
        self.text = text
    }

    convenience init() {
        self.init(title: "", text: "")
    }
    
    var description: String {
        "<title=\(title), text=\(text), displayOrder=\(displayOrder), dateAdded = \(dateAdded)>"
    }
    
    func copy(from text: MemoryText) {
        self.title = text.title
        self.text = text.text
    }
}
