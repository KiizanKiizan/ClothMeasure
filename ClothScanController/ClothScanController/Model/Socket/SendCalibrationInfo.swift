//
//  SendCalibrationInfo.swift
//  ClothScanController
//
//  Created by 岩井宏晃 on 2018/05/15.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

class SendCalibrationInfo {
    private let socketHandler: SocketHandler
    
    var busy: Bool {
        get {
            return socketHandler.busy
        }
    }
    
    init(socketHandler: SocketHandler) {
        self.socketHandler = socketHandler
    }
    
    func sendCalibrationInfo(calibrationInfo: Float, completion: @escaping (SocketError?) -> Void) {
        let sendCalibrationInfoRequest = SendCalibrationInfoRequest(calibrationInfo: calibrationInfo)
        socketHandler.exec(request: sendCalibrationInfoRequest) { (error) in
            completion(error)
        }
    }
}
