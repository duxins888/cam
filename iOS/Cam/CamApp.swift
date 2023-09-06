//
//  CamApp.swift
//  Cam
//
//  Created by Xin Du on 2023/09/06.
//

import SwiftUI

@main
struct CamApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Client.shared)
        }
    }
}
