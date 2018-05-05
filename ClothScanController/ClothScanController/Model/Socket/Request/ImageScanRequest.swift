//
//  ImageScanRequest.swift
//  ClothScanController
//
//  Created by 岩井 宏晃 on 2018/05/01.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation
import UIKit

enum ImageScanRequestState: Int {
    case sendCommand
    case waitImageSize
    case waitImage
}

class ImageScanRequest: Request {
    private var state = ImageScanRequestState.sendCommand
    private var imageSize: Int?
    private(set) var image: UIImage?
    private(set) var imageData: Data?
    
    override func action() {
        delegate?.request(self, write: createCommand(command: .scan), timeout: 30.0)
    }
    
    override func didWrite() {
        switch state {
        case .sendCommand:
            delegate?.request(self, readData: Request.commandLength, timeout: 30.0)
        case .waitImageSize:
            if let size = imageSize {
                print("read image size: \(size)")
                delegate?.request(self, readData: size, timeout: 30.0)
            } else {
                delegate?.request(self, didError: .notFetchedImageSize)
            }
        case .waitImage:
            break
        }
        nextState()
    }
    
    override func recievedCommand(command: RecieveCommand) {
    }
    
    override func didRead(data: Data) {
        switch state {
        case .sendCommand:
            break
        case .waitImageSize:
            if let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : String],
                let sizeString = dict[Request.intToString(integer: DataKey.imageSize.rawValue)],
                let size = Int(sizeString) {
                imageSize = size
                delegate?.request(self, write: createCommand(command: .fetchImage), timeout: 30.0)
            } else {
                delegate?.request(self, didError: .unknownData)
            }
        case .waitImage:
            if let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Data],
                let _imageData = dict[Request.intToString(integer: DataKey.image.rawValue)] {
                imageData = _imageData
                image = UIImage(data: _imageData)
                delegate?.requestDidFinish(self)
            } else {
                delegate?.request(self, didError: .unknownData)
            }
        }
    }
    
    private func nextState() {
        guard let next = ImageScanRequestState(rawValue: state.rawValue + 1) else {
            return
        }
        state = next
    }
}
