//
//  MyApp.swift
//  CamServer
//
//  Created by Xin Du on 2023/09/06.
//

import SwiftUI

@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor var delegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Server.shared)
        }
    }
}
