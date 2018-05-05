//
//  ScanImageRequest.swift
//  ClothMeasure
//
//  Created by 岩井 宏晃 on 2018/05/05.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

enum ScanImageRequestState: Int {
    case sendCommand
}

class ScanImageRequest: Request {
    private var state = ScanImageRequestState.sendCommand
    
    override func action() {
        delegate?.request(self, write: createCommand(command: .scanImage), timeout: 30.0)
    }
    
    override func didWrite() {
        switch state {
        case .sendCommand:
            delegate?.requestDidFinish(self)
        }
    }
    
    override func didRead(data: Data) {
    }
    
    override func recievedCommand(command: RecieveCommand) {
    }
}
