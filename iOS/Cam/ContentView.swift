//
//  ContentView.swift
//  Cam
//
//  Created by Xin Du on 2023/09/06.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var client: Client
    
    @AppStorage("host_address") var host = ""
    
    @State private var port = String(Client.PORT)
    @State private var image: UIImage?
    
    @State private var showPicker = false
    
    var body: some View {
        NavigationStack {
            if client.isConncted {
                cameraButton()
                    .navigationTitle(host)
            } else {
                networkView()
                    .navigationTitle("")
            }
        }
    }
    
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.secondary)
            .frame(width: 100, alignment: .leading)
    }
    
    /// 服务器设置视图
    private func networkView() -> some View {
        Form {
            Section {
                HStack {
                    fieldLabel("IPアドレス")
                    TextField("", text: $host)
                        .keyboardType(.decimalPad)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                HStack {
                    fieldLabel("ポート番号")
                    TextField(String(Client.PORT), text: $port)
                        .keyboardType(.numberPad)
                }
            } header: {
                Text("ネットワーク")
            }
            
            connectButton()
        }
    }
    
    /// 连接服务器按钮
    @ViewBuilder
    private func connectButton() -> some View {
        if client.isConnecting {
            Button(role: .destructive) {
                client.cancel()
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            } label: {
                HStack(spacing: 10) {
                    ProgressView()
                        .id(UUID())
                    Text("接続中")
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        } else {
            Button {
                client.connect(host, port)
                hideKeyboard()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                Text("接続")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .alert("Error", isPresented: $client.showError) {
            } message: {
                Text(client.lastError)
            }
        }
    }
    
    private func cameraButton() -> some View {
        ZStack {
            Button {
                client.msg = ""
                showPicker = true
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            } label: {
                Image(systemName: "camera")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
                    .padding(30)
                    .background(Color("CameraBtn"))
                    .clipShape(Circle())
            }
            
            VStack {
                Spacer()
                Text(client.msg)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 40)
            
        }
        .fullScreenCover(isPresented: $showPicker) {
            ImagePicker(image: $image)
                .ignoresSafeArea()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    client.cancel()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                }
            }
        }
        .onChange(of: image) { newValue in
            guard let img = newValue, let data = img.jpegData(compressionQuality: 0.9) else { return }
            client.sendImage(data)
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Client.shared)
    }
}
#endif
