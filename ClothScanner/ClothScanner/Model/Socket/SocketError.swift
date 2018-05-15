//
//  SocketError.swift
//  ClothScanner
//
//  Created by 岩井 宏晃 on 2018/05/01.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

enum SocketError: Error {
    case notConnected
    case writeTimeout
    case readTimeout
    case invalidImage
    case notCreatedRequest
    case invalidCommand
    case notSendImageStatus
    case notSendCalibrationInfoStatus
}
