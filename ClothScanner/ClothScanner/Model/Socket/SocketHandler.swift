//
//  SocketHandler.swift
//  ClothScanner
//
//  Created by 岩井 宏晃 on 2018/04/29.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

protocol SocketHandlerDelegate: class {
    func socketHandlerDidConnect(_ handler: SocketHandler)
    func socketHandlerRecievedScanRequest(_ handler: SocketHandler)
}

class SocketHandler: NSObject, GCDAsyncSocketDelegate, RequestDelegate {
    private static let previousHostKey = "previousHostKey"
    
    private let toSocket = GCDAsyncSocket()
    weak var delegate: SocketHandlerDelegate?
    private(set) var previousHost = ""
    var busy: Bool {
        get {
            return request != nil
        }
    }
    private var completion: ((SocketError?) -> Void)?
    private var request: Request?
    var connected: Bool {
        get {
            return toSocket.isConnected
        }
    }
    private var waitCommand = false
    
    override init() {
        super.init()
        toSocket.delegate = self
        toSocket.delegateQueue = DispatchQueue.main
    }
    
    func connect(ipAddress: String) {
        do {
            try toSocket.connect(toHost: ipAddress, onPort: 8080)
        } catch let err {
            print("\(err)")
        }
    }
    
    func ready() {
        if !waitCommand {
            toSocket.readData(toLength: UInt(Request.commandLength), withTimeout: -1, tag: 0)
            waitCommand = true
        }
    }
    
    func sendImage(image: UIImage, completion: @escaping (SocketError?) -> Void) {
        if let data = UIImageJPEGRepresentation(image, 0.5) {
            request = SendImageRequest(imageData: data)
            send(request: request!, completion: { (error) in
                completion(error)
            })
        } else {
            completion(.invalidImage)
        }
    }
    
    private func send(request: Request, completion: ((SocketError?) -> Void)?) {
        self.completion = completion
        if toSocket.isConnected {
            self.request = request
            request.delegate = self
            request.action()
        } else {
            execCompletion(error: .notConnected)
        }
    }
    
    private func execCompletion(error: SocketError?) {
        completion?(error)
        completion = nil
        request = nil
        ready()
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("didConnect")
        previousHost = host
        UserDefaults.standard.set(host, forKey: SocketHandler.previousHostKey)
        ready()
        delegate?.socketHandlerDidConnect(self)
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        if request == nil {
            execCompletion(error: .notCreatedRequest)
        } else {
            request?.didWrite()
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        if let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : String],
            let commandString = dict[Request.intToString(integer: DataKey.command.rawValue)],
            let command = Int(commandString),
            let recieveCommand = RecieveCommand(rawValue: command) {
            waitCommand = false
            switch recieveCommand {
            case .scan:
                delegate?.socketHandlerRecievedScanRequest(self)
            default:
                if request == nil {
                    execCompletion(error: .notCreatedRequest)
                } else {
                    request?.recievedCommand(command: recieveCommand)
                }
            }
        } else {
            execCompletion(error: .invalidCommand)
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        execCompletion(error: .writeTimeout)
        return 0.0
    }
    
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        execCompletion(error: .readTimeout)
        return 0.0
    }
    
    func request(_ request: Request, write dict: [String : Any], timeout: TimeInterval) {
        if toSocket.isConnected {
            let data = NSKeyedArchiver.archivedData(withRootObject: dict)
            print("send data size: \(data.count)")
            toSocket.write(data, withTimeout: timeout, tag: 0)
        } else {
            execCompletion(error: .notConnected)
        }
    }
    
    func request(_ request: Request, readData length: Int, timeout: TimeInterval) {
        if toSocket.isConnected {
            toSocket.readData(toLength: UInt(length), withTimeout: timeout, tag: 0)
        } else {
            execCompletion(error: .notConnected)
        }
    }
    
    func requestDidFinish(_ request: Request) {
        execCompletion(error: nil)
    }
    
    func request(_ request: Request, didError error: SocketError) {
        execCompletion(error: error)
    }
}
