//
//  ContentView.swift
//  CamServer
//
//  Created by Xin Du on 2023/09/06.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var server: Server
    
    var body: some View {
        ZStack {
            if server.isReady {
                imageBrowser()
            } else {
                startButton()
            }
        }
        .navigationTitle(server.ipAddresses.joined(separator: ", "))
    }
    
    /// 图片浏览分栏
    private func imageBrowser() -> some View {
        NavigationSplitView {
            List(server.images, id: \.self, selection: $server.lastImage) { name in
                Text(name)
            }
            .frame(width: 200)
            .frame(minWidth: 200)
        } detail: {
            if let imageName = server.lastImage, let nsImage = NSImage.fromDocuments(named: imageName) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
    
    /// 启动服务器按钮
    private func startButton() -> some View {
        VStack {
            Button {
                server.start()
            } label: {
                VStack(spacing: 10) {
                    Image(systemName: "power")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Start Server")
                }
            }
            .buttonStyle(.borderless)
            .alert("Error", isPresented: $server.showError) {
            } message: {
                Text(server.lastError)
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Server.shared)
    }
}
#endif
