//
//  MeasurePointPair.swift
//  BodyMeasure
//
//  Created by 岩井 宏晃 on 2018/06/06.
//  Copyright © 2018年 kiizankiizan. All rights reserved.
//

import Foundation
import UIKit

protocol MeasurePointPairDelegate: class {
    func measurePointPair(_ controller: MeasurePointPair, DidSelectPointView selectedView: MeasurePointView)
    func measurePointPair(_ controller: MeasurePointPair, DidDeselectPointView deselectedView: MeasurePointView)
    func measurePointPair(_ controller: MeasurePointPair, SelectedViewDidMove pos: CGPoint)
}

class MeasurePointPair: MeasurePointViewDelegate {
    let type: MeasurePointType
    private(set) var pointViews = [MeasurePointView]()
    let shapeLayer = CAShapeLayer()
    weak var delegate: MeasurePointPairDelegate?
    let isFixY: Bool
    
    init(type: MeasurePointType, points: [CGPoint], isFixY: Bool) {
        self.type = type
        self.isFixY = isFixY
        points.forEach {
            let pointView = MeasurePointView.create(pos: $0)
            pointView.isFixY = isFixY
            let color = type.color()
            pointView.setColor(color)
            pointView.delegate = self
            self.pointViews.append(pointView)
            
            shapeLayer.strokeColor = color.cgColor
            shapeLayer.lineWidth = 2.0
            shapeLayer.fillColor = color.cgColor
        }
    }
    
    private func updateLine() {
        let uiPath = UIBezierPath()
        for (index, view) in pointViews.enumerated() {
            if index == 0 {
                uiPath.move(to: view.center)
            } else {
                uiPath.addLine(to: view.center)
            }
        }
        shapeLayer.path = uiPath.cgPath
    }
    
    private func clearLine() {
        shapeLayer.path = nil
    }
    
    func y() -> CGFloat? {
        guard let first = pointViews.first, let last = pointViews.last else {
            return nil
        }
        return (last.frame.origin.y + first.frame.origin.y) / 2.0
    }
    
    func measurePointViewDidSelectPointView(_ view: MeasurePointView) {
        delegate?.measurePointPair(self, DidSelectPointView: view)
        updateLine()
    }
    
    func measurePointViewDidDeselectPointView(_ view: MeasurePointView) {
        delegate?.measurePointPair(self, DidDeselectPointView: view)
        clearLine()
    }
    
    func measurePointView(_ view: MeasurePointView, DidMove pos: CGPoint) {
        delegate?.measurePointPair(self, SelectedViewDidMove: pos)
        updateLine()
    }
}
