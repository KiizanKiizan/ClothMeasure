//
//  RecieveCommand.swift
//  ClothScanner
//
//  Created by 岩井 宏晃 on 2018/05/01.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

enum RecieveCommand: Int {
    case scan = 2
    case fetchImage
    case sendImage // 未使用
    case calibration
    case fetchCalibrationInfo
    case sendCalibrationInfo // 未使用
}
