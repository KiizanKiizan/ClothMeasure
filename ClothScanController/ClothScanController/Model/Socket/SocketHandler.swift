//
//  SocketHandler.swift
//  ClothScanController
//
//  Created by 岩井 宏晃 on 2018/04/30.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

protocol SocketHandlerDelegate: class {
    func socketHandlerDidConnect(_ handler: SocketHandler)
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
    
    func scan(completion: @escaping (UIImage?, SocketError?) -> Void) {
        let imageScanRequest = ImageScanRequest()
        exec(request: imageScanRequest) { (error) in
            if error != nil {
                completion(nil, error)
            } else {
                if let image = imageScanRequest.image {
                    completion(image, nil)
                } else {
                    completion(nil, .notFetchedImage)
                }
            }
        }
    }
    
    private func exec(request: Request, completion: @escaping (SocketError?) -> Void) {
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
    }
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        if connectedSocket != nil {
            return
        }
        
        print("didAcceptNewSocket")
        connectedSocket = newSocket
        delegate?.socketHandlerDidConnect(self)
    }
    
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        execCompletion(error: .writeTimeout)
        return 0.0
    }
    
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        execCompletion(error: .readTimeout)
        return 0.0
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        request?.didWrite()
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("recieved")
        request?.didRead(data: data)
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
