//
//  HeadPoint.swift
//  BodyMeasure
//
//  Created by 岩井 宏晃 on 2018/06/13.
//  Copyright © 2018年 kiizankiizan. All rights reserved.
//

import Foundation
import UIKit

class HeadPoint {
    let frontHeadPointView: MeasurePointView
    let sideHeadPointView: MeasurePointView
    
    init(frontHeadInitialPos: CGPoint, sideHeadInitialPos: CGPoint) {
        frontHeadPointView = MeasurePointView.create(pos: frontHeadInitialPos)
        sideHeadPointView = MeasurePointView.create(pos: sideHeadInitialPos)
        let color = UIColor.blue
        frontHeadPointView.setColor(color)
        sideHeadPointView.setColor(color)
    }
}
