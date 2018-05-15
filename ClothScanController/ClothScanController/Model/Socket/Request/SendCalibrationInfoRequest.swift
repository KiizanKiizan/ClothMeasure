//
//  SendCalibrationInfoRequest.swift
//  ClothScanController
//
//  Created by 岩井宏晃 on 2018/05/15.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

enum SendCalibrationInfoRequestState: Int {
    case sendCommand
    case sendCalibrationInfoSize
    case sendCalibrationInfo
}

class SendCalibrationInfoRequest: Request {
    private var state = SendCalibrationInfoRequestState.sendCommand
    let calibrationInfo: Float
    
    init(calibrationInfo: Float) {
        self.calibrationInfo = calibrationInfo
    }
    
    override func action() {
        delegate?.request(self, write: createCommand(command: .sendCalibrationInfo), timeout: 30.0)
    }
    
    override func didWrite() {
        switch state {
        case .sendCommand, .sendCalibrationInfoSize:
            delegate?.request(self, readData: Request.commandLength, timeout: 30.0)
        case .sendCalibrationInfo:
            delegate?.requestDidFinish(self)
        }
        nextState()
    }
    
    override func recievedCommand(command: RecieveCommand) {
        switch command {
        case .fetchCalibrationInfoSize:
            delegate?.request(self, write: [Request.intToString(integer: DataKey.calibrationInfoSize.rawValue) : Request.intToString(integer: calibrationInfoSize())], timeout: 30.0)
        case .fetchCalibrationInfo:
            delegate?.request(self, write: sendCalibrationInfo(), timeout: 30.0)
        default:
            break
        }
    }
    
    override func didRead(data: Data) {
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
