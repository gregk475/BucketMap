//
//  BucketMapApp.swift
//  BucketMap
//
//  Created by Greg Kapp on 2/15/26.
//



import SwiftUI
import SwiftData

@main
struct BucketMapApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: BucketLocation.self) // This initializes your database
    }
}
