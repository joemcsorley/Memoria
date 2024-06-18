//
//  MemoriaApp.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/27/23.
//

import SwiftUI
import SwiftData

@main
struct MemoriaApp: App {
    let navCoordinator = NavigationCoordinator<AppScreens>()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MemoryText.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationRootView(navCoordinator: navCoordinator)
        }
        .modelContainer(sharedModelContainer)
    }
}
