//
//  DataKey.swift
//  ClothScanController
//
//  Created by 岩井 宏晃 on 2018/05/01.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

enum DataKey: Int {
    // 0スタートだとなぜかDataに変換した時のサイズがおかしくなる。要調査。
    case command = 2
    case imageSize
    case image
}
