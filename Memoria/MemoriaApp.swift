//
//  MemoriaApp.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/27/23.
//

import SwiftUI
import SwiftData

// TODO: Change the App DisplayName, and Bundle Identifier back to normal, when done testing.
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
        } catch {
            fatalError("MemoriaApp:  Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationRootView(navCoordinator: navCoordinator)
        }
        .modelContainer(sharedModelContainer)
    }
}
