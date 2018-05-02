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
    
    private(set) var isStarted = false
    private let listenSocket = GCDAsyncSocket()
    private var connectedSocket: GCDAsyncSocket?
    weak var delegate: SocketHandlerDelegate?
    var busy: Bool {
        get {
            return request != nil
        }
    }
    private var completion: ((SocketError?) -> Void)?
    private var request: Request?
    
    override init() {
        super.init()
        listenSocket.delegate = self
        listenSocket.delegateQueue = DispatchQueue.main
    }
    
    func start() {
        if isStarted {
            return
        }
        do {
            try listenSocket.accept(onPort: 8080)
            isStarted = true
        } catch let err {
            print("\(err)")
        }
    }
    
    func ready() {
        if let socket = connectedSocket {
            socket.readData(toLength: UInt(Request.commandLength), withTimeout: -1, tag: 0)
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
        if connectedSocket != nil && connectedSocket!.isConnected {
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
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        if connectedSocket != nil {
            return
        }
        
        print("didAcceptNewSocket")
        connectedSocket = newSocket
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
        if let socket = connectedSocket {
            let data = NSKeyedArchiver.archivedData(withRootObject: dict)
            socket.write(data, withTimeout: timeout, tag: data.count)
        } else {
            execCompletion(error: .notConnected)
        }
    }
    
    func request(_ request: Request, readData length: Int, timeout: TimeInterval) {
        if let socket = connectedSocket {
            socket.readData(toLength: UInt(length), withTimeout: timeout, tag: 0)
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
