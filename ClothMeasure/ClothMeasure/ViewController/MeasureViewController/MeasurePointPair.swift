//
//  MeasurePointPair.swift
//  ClothMeasure
//
//  Created by 岩井宏晃 on 2018/05/09.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation
import UIKit

class MeasurePointPair: MeasurePointViewControllerNotification {
    let type: MeasurePointType
    private(set) var startMeasurePointVc: MeasurePointViewController?
    private(set) var endMeasurePointVc: MeasurePointViewController?
    var shapeLayer: CAShapeLayer?
    
    init(type: MeasurePointType,
         startMeasurePointVc: MeasurePointViewController,
         endMeasurePointVc: MeasurePointViewController) {
        self.type = type
        self.startMeasurePointVc = startMeasurePointVc
        self.endMeasurePointVc = endMeasurePointVc
        startMeasurePointVc.addObserver(self)
        endMeasurePointVc.addObserver(self)
    }
    
    func invalidate() {
        startMeasurePointVc?.removeObserver(self)
        endMeasurePointVc?.removeObserver(self)
        startMeasurePointVc = nil
        endMeasurePointVc = nil
        shapeLayer = nil
    }
    
    func updateLine() {
        guard let start = startMeasurePointVc, let end = endMeasurePointVc else {
            return
        }
        
        let uiPath = UIBezierPath()
        uiPath.move(to: start.measurePoint.pos)
        uiPath.addLine(to: end.measurePoint.pos)
        
        shapeLayer?.path = uiPath.cgPath
    }
    
    func measurePointViewControllerDidCreateMeasurePoint(_ vc: MeasurePointViewController) {
        if startMeasurePointVc?.measurePoint != nil && endMeasurePointVc?.measurePoint != nil {
            updateLine()
        }
    }
    
    func measurePointViewControllerDidMove(_ vc: MeasurePointViewController) {
        updateLine()
    }
}
