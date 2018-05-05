//
//  SendImageRequest.swift
//  ClothScanController
//
//  Created by 岩井 宏晃 on 2018/05/03.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

import UIKit

enum SendImageRequestState: Int {
    case sendCommand
    case sendImageSize
    case sendImage
}

class SendImageRequest: Request {
    private var state = SendImageRequestState.sendCommand
    let imageData: Data
    
    init(imageData: Data) {
        self.imageData = imageData
    }
    
    override func action() {
        delegate?.request(self, write: createCommand(command: .sendImage), timeout: 30.0)
    }
    
    override func didWrite() {
        switch state {
        case .sendCommand, .sendImageSize:
            delegate?.request(self, readData: Request.commandLength, timeout: 30.0)
        case .sendImage:
            delegate?.requestDidFinish(self)
        }
        nextState()
    }
    
    override func recievedCommand(command: RecieveCommand) {
        switch command {
        case .fetchImageSize:
            delegate?.request(self, write: [Request.intToString(integer: DataKey.imageSize.rawValue) : Request.intToString(integer: imageDataSize())], timeout: 30.0)
        case .fetchImage:
            delegate?.request(self, write: sendImageData(), timeout: 30.0)
        case .scanImage:
            break
        }
    }
    
    override func didRead(data: Data) {
    }
    
    private func nextState() {
        guard let next = SendImageRequestState(rawValue: state.rawValue + 1) else {
            return
        }
        state = next
    }
    
    private func sendImageData() -> [String : Data] {
        return [Request.intToString(integer: DataKey.image.rawValue) : imageData]
    }
    
    private func imageDataSize() -> Int {
        return NSKeyedArchiver.archivedData(withRootObject: sendImageData()).count
    }
}
