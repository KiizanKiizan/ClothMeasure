//
//  MeasurePointPair.swift
//  ClothMeasure
//
//  Created by 岩井宏晃 on 2018/05/09.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation
import UIKit

class MeasurePointPair {
    let type: MeasurePointType
    let startMeasurePointVc: MeasurePointViewController
    let endMeasurePointVc: MeasurePointViewController
    
    init(type: MeasurePointType,
         xUnit: CGFloat,
         yUnit: CGFloat,
         initStartPosRatio: CGPoint,
         initEndPosRatio: CGPoint) {
        self.type = type
        let startMeasurePoint = MeasurePoint(xUnit: xUnit,
                                             yUnit: yUnit,
                                             initPosRatio: initStartPosRatio)
        let endMeasurePoint = MeasurePoint(xUnit: xUnit,
                                           yUnit: yUnit,
                                           initPosRatio: initEndPosRatio)
        
        self.startMeasurePointVc = MeasurePointViewController.createViewController(measurePoint: startMeasurePoint)
        self.endMeasurePointVc = MeasurePointViewController.createViewController(measurePoint: endMeasurePoint)
    }
}
