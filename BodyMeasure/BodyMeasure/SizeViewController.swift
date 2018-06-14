//
//  SizeViewController.swift
//  BodyMeasure
//
//  Created by 岩井 宏晃 on 2018/06/14.
//  Copyright © 2018年 kiizankiizan. All rights reserved.
//

import UIKit

class SizeViewController: UIViewController {
    
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var drawContainer: UIView!
    
    var frontPointPairs = [MeasurePointPair]()
    var sidePointPairs = [MeasurePointPair]()
    
    var frontCentimeterPerPoint: CGFloat = 0.0
    var sideCentimeterPerPoint: CGFloat = 0.0
    
    let shapeLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = UIColor.red
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 4.0
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        drawContainer.layer.addSublayer(shapeLayer)
    }
    
    func update() {
        guard let front = frontPointPairs.first, let side = sidePointPairs.first else {
            return
        }
        
        let coef = (frontCentimeterPerPoint / sideCentimeterPerPoint)
        let frontPositions = front.pointViews.map { CGPoint(x: $0.frame.origin.x * coef, y: $0.frame.origin.y * coef) }
        let sidePositions = side.pointViews.map { CGPoint(x: $0.frame.origin.x, y: $0.frame.origin.y) }
        let frontLength = frontPositions[1].x - frontPositions[0].x
        let sideTopToCenterLength = sidePositions[1].x - sidePositions[0].x
        let sideTopToBottomLength = sidePositions[2].x - sidePositions[0].x
        
        let topPos = CGPoint(x: drawContainer.bounds.width / 2.0, y: 0.0)
        let leftPos = CGPoint(x: topPos.x - frontLength / 2.0, y: sideTopToCenterLength)
        let rightPos = CGPoint(x: topPos.x + frontLength / 2.0, y: sideTopToCenterLength)
        let bottomPos = CGPoint(x: topPos.x, y: sideTopToBottomLength)
        
        let leftTop = CGPoint(x: leftPos.x, y: topPos.y)
        let leftBottom = CGPoint(x: leftPos.x, y: bottomPos.y)
        let rightTop = CGPoint(x: rightPos.x, y: topPos.y)
        let rightBottom = CGPoint(x: rightPos.x, y: bottomPos.y)
        
        let path = UIBezierPath()
        path.move(to: topPos)
        path.addQuadCurve(to: leftPos, controlPoint: leftTop)
        path.addQuadCurve(to: bottomPos, controlPoint: leftBottom)
        path.addQuadCurve(to: rightPos, controlPoint: rightBottom)
        path.addQuadCurve(to: topPos, controlPoint: rightTop)
        
        shapeLayer.path = path.cgPath
    }
}
