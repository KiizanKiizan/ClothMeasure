//
//  SendImageRequest.swift
//  ClothScanner
//
//  Created by 岩井 宏晃 on 2018/05/01.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

enum SendImageRequestState: Int {
    case sendImageSize
    case sendImage
}

class SendImageRequest: Request {
    private var state = SendImageRequestState.sendImageSize
    private let imageData: Data
    
    init(imageData: Data) {
        self.imageData = imageData
    }
    
    override func action() {
        let data = NSKeyedArchiver.archivedData(withRootObject: [Request.intToString(integer: DataKey.image.rawValue) : imageData])
        delegate?.request(self, write: [Request.intToString(integer: DataKey.imageSize.rawValue) : Request.intToString(integer: data.count)], timeout: 30.0)
    }
    
    override func didWrite() {
        switch state {
        case .sendImageSize:
            delegate?.request(self, readData: Request.commandLength, timeout: 30.0)
        case .sendImage:
            delegate?.requestDidFinish(self)
        }
        nextState()
    }
    
    override func recievedCommand(command: RecieveCommand) {
        switch command {
        case .fetchImage:
            if state == .sendImage {
                delegate?.request(self, write: [Request.intToString(integer: DataKey.image.rawValue) : imageData], timeout: 30.0)
            } else {
                delegate?.request(self, didError: .notSendImageStatus)
            }
        default:
            break
        }
    }
    
    private func nextState() {
        guard let next = SendImageRequestState(rawValue: state.rawValue + 1) else {
            return
        }
        state = next
    }
}
