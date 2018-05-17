//
//  SendCalibrationInfoRequest.swift
//  ClothScanner
//
//  Created by 岩井宏晃 on 2018/05/15.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

enum SendCalibrationInfoRequestState: Int {
    case sendCalibrationInfoSize
    case sendCalibrationInfo
}

class SendCalibrationInfoRequest: Request {
    private var state = SendCalibrationInfoRequestState.sendCalibrationInfoSize
    let calibrationInfo: Float
    
    init(calibrationInfo: Float) {
        self.calibrationInfo = calibrationInfo
    }
    
    override func action() {
        delegate?.request(self, write: [Request.intToString(integer: DataKey.calibrationInfoSize.rawValue) : Request.intToString(integer: calibrationInfoSize())], timeout: 30.0)
    }
    
    override func didWrite() {
        switch state {
        case .sendCalibrationInfoSize:
            delegate?.request(self, readData: Request.commandLength, timeout: 30.0)
        case .sendCalibrationInfo:
            delegate?.requestDidFinish(self)
        }
        nextState()
    }
    
    override func recievedCommand(command: RecieveCommand) {
        switch command {
        case .fetchCalibrationInfo:
            if state == .sendCalibrationInfo {
                delegate?.request(self, write: sendCalibrationInfo(), timeout: 30.0)
            } else {
                delegate?.request(self, didError: .notSendCalibrationInfoStatus)
            }
        default:
            break
        }
    }
    
    private func nextState() {
        guard let next = SendCalibrationInfoRequestState(rawValue: state.rawValue + 1) else {
            return
        }
        state = next
    }
    
    private func sendCalibrationInfo() -> [String : Float] {
        return [Request.intToString(integer: DataKey.calibrationInfo.rawValue) : calibrationInfo]
    }
    
    private func calibrationInfoSize() -> Int {
        return NSKeyedArchiver.archivedData(withRootObject: sendCalibrationInfo()).count
    }
}
