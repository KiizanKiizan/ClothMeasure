//
//  FetchCalibrationInfo.swift
//  ClothMeasure
//
//  Created by 岩井 宏晃 on 2018/05/16.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

class FetchCalibrationInfo {
    private let socketHandler: SocketHandler
    
    var busy: Bool {
        get {
            return socketHandler.busy
        }
    }
    
    init(socketHandler: SocketHandler) {
        self.socketHandler = socketHandler
    }
    
    func fetch(completion: @escaping (Float?, SocketError?) -> Void) {
        let fetchCalibrationInfoRequest = FetchCalibrationInfoRequest()
        socketHandler.exec(request: fetchCalibrationInfoRequest) { (error) in
            if error != nil {
                completion(nil, error)
            } else {
                completion(fetchCalibrationInfoRequest.calibrationInfo, nil)
            }
        }
    }
}
