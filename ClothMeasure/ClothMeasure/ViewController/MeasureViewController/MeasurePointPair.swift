//
//  MeasurePointPair.swift
//  ClothMeasure
//
//  Created by 岩井宏晃 on 2018/05/09.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation
import UIKit

protocol MeasurePointPairDelegate: class {
    func measurePointPairDidMovePoint(_ controller: MeasurePointPair)
}

class MeasurePointPair: MeasurePointViewControllerNotification {
    let type: MeasurePointType
    private(set) var startMeasurePointVc: MeasurePointViewController?
    private(set) var endMeasurePointVc: MeasurePointViewController?
    var shapeLayer: CAShapeLayer?
    weak var delegate: MeasurePointPairDelegate?
    
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
    
    func distance() -> Float {
        guard let startPoint = startMeasurePointVc?.measurePoint, let endPoint = endMeasurePointVc?.measurePoint else {
            return 0.0
        }
        
        let diffX = Float(startPoint.pos.x) - Float(endPoint.pos.x)
        let diffY = Float(startPoint.pos.y) - Float(endPoint.pos.y)
        
        return sqrtf(diffX * diffX + diffY * diffY)
    }
    
    func measurePointViewControllerDidCreateMeasurePoint(_ vc: MeasurePointViewController) {
        if startMeasurePointVc?.measurePoint != nil && endMeasurePointVc?.measurePoint != nil {
            updateLine()
            delegate?.measurePointPairDidMovePoint(self)
        }
    }
    
    func measurePointViewControllerDidMove(_ vc: MeasurePointViewController) {
        updateLine()
        delegate?.measurePointPairDidMovePoint(self)
    }
}
