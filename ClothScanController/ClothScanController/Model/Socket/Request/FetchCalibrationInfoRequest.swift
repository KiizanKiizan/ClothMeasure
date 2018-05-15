//
//  FetchCalibrationInfoRequest.swift
//  ClothScanController
//
//  Created by 岩井宏晃 on 2018/05/15.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

enum FetchCalibrationInfoRequestState: Int {
    case sendCommand
    case waitCaribrationInfoSize
    case waitCaribrationInfo
}

class FetchCalibrationInfoRequest: Request {
    private var state = FetchCalibrationInfoRequestState.sendCommand
    private var infoSize: Int?
    private(set) var calibrationInfo: Float = 0.0
    
    override func action() {
        delegate?.request(self, write: createCommand(command: .calibration), timeout: 30.0)
    }
    
    override func didWrite() {
        switch state {
        case .sendCommand:
            delegate?.request(self, readData: Request.commandLength, timeout: 30.0)
        case .waitCaribrationInfoSize:
            if let size = infoSize {
                print("read image size: \(size)")
                delegate?.request(self, readData: size, timeout: 30.0)
            } else {
                delegate?.request(self, didError: .notFetchedCaribrationInfoSize)
            }
        case .waitCaribrationInfo:
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
        case .waitCaribrationInfoSize:
            if let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : String],
                let sizeString = dict[Request.intToString(integer: DataKey.calibrationInfoSize.rawValue)],
                let size = Int(sizeString) {
                infoSize = size
                delegate?.request(self, write: createCommand(command: .fetchCalibrationInfo), timeout: 30.0)
            } else {
                delegate?.request(self, didError: .unknownData)
            }
        case .waitCaribrationInfo:
            if let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Float],
                let _calibrationInfo = dict[Request.intToString(integer: DataKey.calibrationInfo.rawValue)] {
                calibrationInfo = _calibrationInfo
                delegate?.requestDidFinish(self)
            } else {
                delegate?.request(self, didError: .unknownData)
            }
        }
    }
    
    private func nextState() {
        guard let next = FetchCalibrationInfoRequestState(rawValue: state.rawValue + 1) else {
            return
        }
        state = next
    }
}
