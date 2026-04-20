//
//  PflanzenApp.swift
//  Pflanzen
//
//  Created by mo on 20.04.26.
//

import SwiftUI
import SwiftData

@main
struct PflanzenApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Plant.self,
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
            PlantListView()
        }
        .modelContainer(sharedModelContainer)
    }
}
