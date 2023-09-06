//
//  Client.swift
//  Cam
//
//  Created by Xin Du on 2023/09/06.
//

import Foundation
import Network

class Client: ObservableObject {
    /// 默认端口
    static let PORT: UInt16 = 9997
    
    // MARK: - Life Cycle
    static let shared = Client()
    private init() {}
    
    // MARK: - States
    @Published var isConnecting = false {
        didSet {
            if isConnecting {
                isConncted = false
            }
        }
    }
    
    @Published var isConncted = false
    
    // MARK: - Errors
    /// 错误消息
    @Published var lastError: String = "" {
        didSet {
            if lastError.count > 0 {
                showError = true
            }
        }
    }
    
    /// 是否弹出错误提示
    @Published var showError = false
    
    // MARK: - Properties
    var connection: NWConnection!
    
    // MARK: - Public Methods
    
    /// 连接服务器
    /// - Parameters:
    ///   - host: 主机
    ///   - port: 端口
    func connect(_ host: String, _ port: String) {
        guard isConnecting == false else { return }
        isConnecting = true
        connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: UInt16(port)!)!, using: .tcp)
        connection.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready, .cancelled, .failed:
                    self?.isConnecting = false
                default:
                    break
                }
                
                switch state {
                case .ready:
                    self?.isConncted = true
                case .cancelled:
                    self?.isConncted = false
                case .failed(let err):
                    self?.isConncted = false
                    self?.lastError = err.localizedDescription
                default:
                    return
                }
            }
        }
        connection.start(queue: .global())
    }
    
    func sendImage(_ data: Data) {
        guard let conn = connection else { return }
        var len = UInt32(data.count)
        let lenData = withUnsafeBytes(of: &len) { Data($0) }
        
        print("Sending header (\(len)) ...")
        conn.send(content: lenData, completion: .contentProcessed { error in
            if let error {
                print("Failed to send message header with error \(error.localizedDescription)")
                return
            }
            print("Sending image ...")
            conn.send(content: data, completion: .contentProcessed { error in
                if let error {
                    print("Failed to send image with error \(error.localizedDescription)")
                    return
                }
                print("Done.")
            })
        })
    }
    
    /// 断开连接
    func cancel() {
        connection?.cancel()
    }
}


