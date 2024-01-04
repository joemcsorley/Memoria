//
//  LazyWrapperView.swift
//  Memoria
//
//  Created by Joseph McSorley on 1/2/24.
//

import SwiftUI

struct LazyWrapperView<Content: View>: View {
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}
