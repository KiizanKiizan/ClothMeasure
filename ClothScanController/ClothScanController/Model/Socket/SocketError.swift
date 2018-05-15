//
//  SocketError.swift
//  ClothScanController
//
//  Created by 岩井 宏晃 on 2018/04/30.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

enum SocketError: Error {
    case notConnected
    case writeTimeout
    case readTimeout
    case unknownData
    case notFetchedImageSize
    case notFetchedImage
    case notFetchedCaribrationInfoSize
    case notFetchedCaribrationInfo
}
