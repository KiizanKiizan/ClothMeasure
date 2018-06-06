//
//  MeasurePointPair.swift
//  BodyMeasure
//
//  Created by 岩井 宏晃 on 2018/06/06.
//  Copyright © 2018年 kiizankiizan. All rights reserved.
//

import Foundation
import UIKit

class MeasurePointPair {
    let type: MeasurePointType
    private(set) var pointViews = [MeasurePointView]()
    
    init(type: MeasurePointType, points: [CGPoint]) {
        self.type = type
        let pointSize: CGFloat = 44.0
        points.forEach {
            let pointView = MeasurePointView(frame: CGRect(x: $0.x - pointSize / 2.0,
                                                           y: $0.y - pointSize / 2.0,
                                                           width: pointSize,
                                                           height: pointSize))
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:)))
            pointView.addGestureRecognizer(panGesture)
            pointView.setColor(type.color())
            self.pointViews.append(pointView)
        }
    }
    
    @objc func pan(gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view,
            let superView = view.superview else {
            return
        }
        let move = gesture.translation(in: superView)
        gesture.setTranslation(.zero, in: superView)
        view.center = CGPoint(x: view.center.x + move.x,
                              y: view.center.y + move.y)
    }
}
