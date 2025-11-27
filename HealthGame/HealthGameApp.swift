//
//  HealthGameApp.swift
//  HealthGame
//

import SwiftUI
import GoogleSignIn

@main
struct HealthGameApp: App {
    init() {
        _ = SupabaseManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
