//
//  MemoryText.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/28/23.
//

import Foundation
import SwiftData

@Model
final class MemoryText {
    var dateAdded: Date
    @Attribute(.unique) var title: String
    @Attribute(.externalStorage) var text: String

    init(title: String, text: String, dateAdded: Date = Date()) {
        self.dateAdded = dateAdded
        self.title = title
        self.text = text
    }
}
