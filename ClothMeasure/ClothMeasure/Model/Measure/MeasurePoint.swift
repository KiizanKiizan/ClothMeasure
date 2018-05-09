//
//  MeasurePoint.swift
//  ClothMeasure
//
//  Created by 岩井 宏晃 on 2018/05/07.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation
import UIKit

class MeasurePoint {
    
    let xUnit: CGFloat
    let yUnit: CGFloat
    var pos: CGPoint {
        get { return CGPoint(x: xUnit * posRatio.x, y: yUnit * posRatio.y) }
        set { posRatio = CGPoint(x: newValue.x / xUnit, y: newValue.y / yUnit) }
    }
    private var posRatio: CGPoint
    
    init(xUnit: CGFloat,
         yUnit: CGFloat,
         initPosRatio: CGPoint) {
        self.xUnit = xUnit
        self.yUnit = yUnit
        self.posRatio = initPosRatio
    }
}
