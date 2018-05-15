//
//  SendCommand.swift
//  ClothScanController
//
//  Created by 岩井 宏晃 on 2018/04/30.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

enum SendCommand: Int {
    // 0スタートだとなぜかDataに変換した時のサイズがおかしくなる。要調査。
    case scan = 2
    case fetchImage
    case sendImage
    case calibration
    case fetchCalibrationInfo
    case sendCalibrationInfo
}
