//
//  QTMessagingAppApp.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import SwiftUI
import SwiftData

@main
struct QTMessagingAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
		.modelContainer(for: UserInfo.self)
    }
}
