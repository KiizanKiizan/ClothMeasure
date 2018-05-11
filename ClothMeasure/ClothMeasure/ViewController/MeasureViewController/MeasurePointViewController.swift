//
//  MeasurePointViewController.swift
//  ClothMeasure
//
//  Created by 岩井 宏晃 on 2018/05/07.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation
import UIKit

enum CursorPosition {
    case top
    case bottom
    case left
    case right
}

protocol MeasurePointViewControllerNotification: class {
    func measurePointViewControllerDidCreateMeasurePoint(_ vc: MeasurePointViewController)
    func measurePointViewControllerDidMove(_ vc: MeasurePointViewController)
}

class MeasurePointViewController: UIViewController {

    @IBOutlet weak var cursor: UIView!
    @IBOutlet weak var point: UIView!
    
    private var observers = [MeasurePointViewControllerNotification]()
    
    private(set) var initPosRatio: CGPoint!
    private(set) var measurePoint: MeasurePoint!
    private(set) var panGesture: UIPanGestureRecognizer!
    private var cursorPosition: CursorPosition!
    
    private var pointRadius: CGFloat {
        get {
            return point.bounds.width / 2.0
        }
    }
    
    class func createViewController(initPosRatio: CGPoint, cursorPosition: CursorPosition) -> MeasurePointViewController {
        let vc = UIStoryboard(name: "MeasurePointViewController", bundle: nil).instantiateInitialViewController() as! MeasurePointViewController
        vc.initPosRatio = initPosRatio
        vc.panGesture = UIPanGestureRecognizer(target: vc, action: #selector(panCursor))
        vc.cursorPosition = cursorPosition
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = CGRect(x: 0.0,
                            y: 0.0,
                            width: preferredContentSize.width,
                            height: preferredContentSize.height)

        point.layer.cornerRadius = pointRadius
        
        cursor.addGestureRecognizer(panGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if measurePoint == nil {
//            var width = preferredContentSize.width
//            var height = preferredContentSize.height
//            var pointFrame = point.frame
//            var cursorFrame = cursor.frame
//            
//            switch cursorPosition {
//            case .top:
//                pointFrame = CGRect(x: pointFrame.origin.x,
//                                    y: height - pointFrame.height - pointFrame.origin.y,
//                                    width: pointFrame.width,
//                                    height: pointFrame.height)
//                cursorFrame = CGRect(x: cursorFrame.origin.x,
//                                     y: height - cursorFrame.height - cursorFrame.origin.y,
//                                     width: cursorFrame.width,
//                                     height: cursorFrame.height)
//            case .bottom:
//                break
//            case .left:
//                swap(&width, &height)
//                pointFrame = CGRect(x: width - pointFrame.width - pointFrame.origin.y,
//                                    y: pointFrame.origin.x,
//                                    width: pointFrame.width,
//                                    height: pointFrame.height)
//                cursorFrame = CGRect(x: width - cursorFrame.width - pointFrame.origin.y,
//                                     y: cursorFrame.origin.x,
//                                     width: cursorFrame.width,
//                                     height: cursorFrame.height)
//            case .right:
//                swap(&width, &height)
//                pointFrame = CGRect(x: pointFrame.origin.y,
//                                    y: pointFrame.origin.x,
//                                    width: pointFrame.width,
//                                    height: pointFrame.height)
//                cursorFrame = CGRect(x: pointFrame.origin.y,
//                                     y: cursorFrame.origin.x,
//                                     width: cursorFrame.width,
//                                     height: cursorFrame.height)
//            default:
//                break
//            }
//            
//            view.frame = CGRect(x: 0.0,
//                                y: 0.0,
//                                width: width,
//                                height: height)
//            
//            point.frame = pointFrame
//            cursor.frame = cursorFrame
            
            let superViewBounds = view.superview!.bounds
            measurePoint = MeasurePoint(xUnit: superViewBounds.width / 2.0,
                                        yUnit: superViewBounds.height / 2.0,
                                        initPosRatio: initPosRatio)
            let pos = view.convert(measurePoint.pos, to: point)
            view.frame = CGRect(x: pos.x - pointRadius,
                                y: pos.y - pointRadius,
                                width: view.bounds.width,
                                height: view.bounds.height)
            observers.forEach{ $0.measurePointViewControllerDidCreateMeasurePoint(self) }
        }
    }
    
    func addObserver(_ observer: MeasurePointViewControllerNotification) {
        if !observers.contains(where: {$0 === observer}) {
            observers.append(observer)
        }
    }
    
    func removeObserver(_ observer: MeasurePointViewControllerNotification) {
        if let index = observers.index(where: {$0 === observer}) {
            observers.remove(at: index)
        }
    }

    @objc func panCursor(sender: UIPanGestureRecognizer) {
        let move = sender.translation(in: view)
        sender.setTranslation(.zero, in: view)
        view.frame = CGRect(x: view.frame.origin.x + move.x,
                            y: view.frame.origin.y + move.y,
                            width: view.bounds.width,
                            height: view.bounds.height)
        var pos = view.convert(point.frame.origin, to: view.superview)
        pos.x += pointRadius
        pos.y += pointRadius
        measurePoint.pos = pos
        
        observers.forEach{ $0.measurePointViewControllerDidMove(self) }
    }
}
