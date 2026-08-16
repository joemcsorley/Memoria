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
    @State private var navCoordinator = NavigationCoordinator<AppScreens>()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([MemoryText.self])
        let modelConfiguration = ModelConfiguration(schema: schema)

        do {
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            dataStores.modelContainer = modelContainer
            return modelContainer
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
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
