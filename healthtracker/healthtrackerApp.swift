//
//  healthtrackerApp.swift
//  healthtracker
//
//  Created by sharon on 3/30/23.
//

import SwiftUI
import Firebase

@main
struct healthtrackerApp: App {
    @StateObject var healthData: HealthData = HealthData()
    
    init() {
            FirebaseApp.configure()
        }

    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(healthData)
        }
    }
}
