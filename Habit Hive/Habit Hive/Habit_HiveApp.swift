//
//  Habit_HiveApp.swift
//  Habit Hive
//
//  Created by Sebastian Weidlinger on 18.05.21.
//

import SwiftUI

@main
struct Habit_HiveApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
