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
    weak var delegate: MeasurePointPairDelegate?
    
    init(type: MeasurePointType, points: [CGPoint]) {
        self.type = type
        let pointSize: CGFloat = 66.0
        points.forEach {
            let pointView = MeasurePointView(frame: CGRect(x: $0.x - pointSize / 2.0,
                                                           y: $0.y - pointSize / 2.0,
                                                           width: pointSize,
                                                           height: pointSize))
            pointView.setColor(type.color())
            pointView.delegate = self
            self.pointViews.append(pointView)
        }
    }
    
    func measurePointViewDidSelectPointView(_ view: MeasurePointView) {
        delegate?.measurePointPair(self, DidSelectPointView: view)
    }
    
    func measurePointViewDidDeselectPointView(_ view: MeasurePointView) {
        delegate?.measurePointPair(self, DidDeselectPointView: view)
    }
    
    func measurePointView(_ view: MeasurePointView, DidMove pos: CGPoint) {
        delegate?.measurePointPair(self, SelectedViewDidMove: pos)
    }
}
