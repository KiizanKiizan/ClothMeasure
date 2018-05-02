//
//  Request.swift
//  ClothScanController
//
//  Created by 岩井 宏晃 on 2018/05/01.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

protocol RequestDelegate: class {
    func request(_ request: Request, write dict: [String : Any], timeout: TimeInterval)
    func request(_ request: Request, readData length: Int, timeout: TimeInterval)
    func requestDidFinish(_ request: Request)
    func request(_ request: Request, didError error: SocketError)
}

class Request {
    
    static let commandLength = 271
    weak var delegate: RequestDelegate?
    
    func action() {
        assertionFailure("need override")
    }
    
    func didWrite() {
        assertionFailure("need override")
    }
    
    func didRead(data: Data) {
        assertionFailure("need override")
    }
    
    func createCommand(command: SendCommand) -> [String : String] {
        return [intToString(integer: DataKey.command.rawValue) : intToString(integer: command.rawValue)]
    }
    
    func intToString(integer: Int) -> String {
        return String(format: "%010d", integer)
    }
}
