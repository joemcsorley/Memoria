//
//  Token.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/21/23.
//

import Foundation

struct Token {
    let value: String
    let startIndex: AttributedString.Index
    let endIndex: AttributedString.Index

    var description: String {
        "(\(value)) \(startIndex)..<\(endIndex)"
    }

    var indexRange: any RangeExpression<AttributedString.Index> {
        startIndex..<endIndex
    }
}
