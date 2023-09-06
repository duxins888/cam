//
//  Server.swift
//  CamServer
//
//  Created by Xin Du on 2023/09/06.
//

import Foundation
import Network


class Server: ObservableObject {
    /// 默认端口
    static let PORT: UInt16 = 9997
    
    // MARK: - Life Cycle
    static let shared = Server()
    private init() {}
    
    // MARK: - States
    @Published var isReady = false
    
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
    
    // MARK: - Images
    
    /// 上传照片文件名列表
    @Published var images = [String]()
    
    /// 最后上传照片文件
    @Published var lastImage: String?
    
    // MARK: - Public Methods
    
    /// 启动服务器
    func start() {
        let port = NWEndpoint.Port(rawValue: Server.PORT)!
        let listener = try! NWListener(using: .tcp, on: port)
        
        listener.newConnectionHandler = { (conn) in
            func receiveNextMessage() {
                // 消息头部 4 个字节表示图片大小
                conn.receive(minimumIncompleteLength: 4, maximumLength: 4) { data, _, isComplete, error in
                    guard let data = data, error == nil else {
                        print("Failed to receive data with error: \(error?.localizedDescription ?? "")")
                        return
                    }
                    
                    var len: UInt32 = 0
                    _ = withUnsafeMutableBytes(of: &len) { data.copyBytes(to: $0) }
                    
                    print("Image size: \(len)")
                    
                    // 根据头部信息获取图片文件
                    conn.receive(minimumIncompleteLength: Int(len), maximumLength: Int(len)) { data, _, isComplete, error in
                        guard let data = data, error == nil else {
                            print("Failed to decode image data with error: \(error?.localizedDescription ?? "")")
                            return
                        }
                        
                        // 保存图片到 Documents 根目录
                        let fileName = self.genImageName()
                        let url = URL.documentsDirectory.appending(path: fileName + ".jpg")
                        try! data.write(to: url)
                        DispatchQueue.main.async {
                            self.images.append(fileName)
                            self.lastImage = fileName
                        }
                        
                        // 读取下一条消息
                        if !isComplete {
                            receiveNextMessage()
                        }
                    }
                }
            }
            
            receiveNextMessage()
            conn.start(queue: .global())
        }
        
        listener.stateUpdateHandler = { [weak self] (state) in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    self?.isReady = true
                case .failed(let err):
                    self?.lastError = err.localizedDescription
                    self?.isReady = false
                case .cancelled:
                    self?.isReady = false
                default:
                    break
                }
            }
        }
        
        listener.start(queue: .global())
    }
    
    /// 当前设备 ip 地址
    lazy var ipAddresses: [String] = {
        var ret = [String]()
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let first = ifaddr else { return [] }
        
        for ptr in sequence(first: first, next: { $0.pointee.ifa_next }) {
            let interface = ptr.pointee
            let family = interface.ifa_addr.pointee.sa_family
            let name = String(cString: interface.ifa_name)
            if name == "en0" && family == UInt8(AF_INET) {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                ret.append(String(cString: hostname))
            }
        }
        freeifaddrs(ifaddr)
        return ret
    }()
    
    // MARK: - Private Methods
    /// 生成文件名
    private func genImageName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH.mm.ss"
        return formatter.string(from: Date())
    }
}
