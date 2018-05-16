//
//  FetchCalibrationInfoRequest.swift
//  ClothMeasure
//
//  Created by 岩井 宏晃 on 2018/05/16.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

enum FetchCalibrationInfoRequestState: Int {
    case sendCommand
    case waitCalibrationInfoSize
    case waitCalibrationInfo
}

class FetchCalibrationInfoRequest: Request {
    private var state = FetchCalibrationInfoRequestState.sendCommand
    private var calibrationInfoSize: Int?
    private(set) var calibrationInfo: Float = 1.0
    
    override func action() {
        delegate?.request(self, write: createCommand(command: .fetchCalibrationInfoSize), timeout: 30.0)
    }
    
    override func didWrite() {
        switch state {
        case .sendCommand:
            delegate?.request(self, readData: Request.commandLength, timeout: 30.0)
        case .waitCalibrationInfoSize:
            if let size = calibrationInfoSize {
                delegate?.request(self, readData: size, timeout: 30.0)
            } else {
                delegate?.request(self, didError: .notFetchedCaribrationInfoSize)
            }
        case .waitCalibrationInfo:
            break
        }
        nextState()
    }
    
    override func didRead(data: Data) {
        switch state {
        case .sendCommand:
            break
        case .waitCalibrationInfoSize:
            if let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : String],
                let sizeString = dict[Request.intToString(integer: DataKey.calibrationInfoSize.rawValue)],
                let size = Int(sizeString) {
                calibrationInfoSize = size
                delegate?.request(self, write: createCommand(command: .fetchCalibrationInfo), timeout: 30.0)
            } else {
                delegate?.request(self, didError: .unknownData)
            }
        case .waitCalibrationInfo:
            if let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Float],
                let data = dict[Request.intToString(integer: DataKey.calibrationInfo.rawValue)] {
                calibrationInfo = data
                delegate?.requestDidFinish(self)
            } else {
                delegate?.request(self, didError: .unknownData)
            }
        }
    }
    
    override func recievedCommand(command: RecieveCommand) {
    }
    
    private func nextState() {
        guard let next = FetchCalibrationInfoRequestState(rawValue: state.rawValue + 1) else {
            return
        }
        state = next
    }
}
