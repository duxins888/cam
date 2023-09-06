//
//  MyApp.swift
//  CamServer
//
//  Created by Xin Du on 2023/09/06.
//

import SwiftUI

@main
struct MyApp: App {
    @StateObject var server = Server.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(server)
        }
    }
}
