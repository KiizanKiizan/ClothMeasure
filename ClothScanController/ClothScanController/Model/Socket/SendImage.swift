//
//  SendImage.swift
//  ClothScanController
//
//  Created by 岩井 宏晃 on 2018/05/03.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

class SendImage {
    private let socketHandler: SocketHandler
    
    var busy: Bool {
        get {
            return socketHandler.busy
        }
    }
    
    init(socketHandler: SocketHandler) {
        self.socketHandler = socketHandler
    }
    
    func sendImage(imageData: Data, completion: @escaping (SocketError?) -> Void) {
        let sendImageRequest = SendImageRequest(imageData: imageData)
        socketHandler.exec(request: sendImageRequest) { (error) in
            completion(error)
        }
    }
}
