//
//  MeasurePointViewController.swift
//  ClothMeasure
//
//  Created by 岩井 宏晃 on 2018/05/07.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit

protocol MeasurePointViewControllerNotification: class {
    func measurePointViewControllerDidCreateMeasurePoint(_ vc: MeasurePointViewController)
    func measurePointViewControllerDidMove(_ vc: MeasurePointViewController)
}

class MeasurePointViewController: UIViewController {

    @IBOutlet weak var cursor: UIImageView!
    @IBOutlet weak var point: UIView!
    @IBOutlet weak var pointWidthConstraint: NSLayoutConstraint!
    
    private var observers = [MeasurePointViewControllerNotification]()
    
    private(set) var initPosRatio: CGPoint!
    private(set) var measurePoint: MeasurePoint!
    private(set) var panGesture: UIPanGestureRecognizer!
    
    class func createViewController(initPosRatio: CGPoint) -> MeasurePointViewController {
        let vc = UIStoryboard(name: "MeasurePointViewController", bundle: nil).instantiateInitialViewController() as! MeasurePointViewController
        vc.initPosRatio = initPosRatio
        vc.panGesture = UIPanGestureRecognizer(target: vc, action: #selector(panCursor))
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = CGRect(x: 0.0,
                            y: 0.0,
                            width: preferredContentSize.width,
                            height: preferredContentSize.height)

        point.layer.cornerRadius = pointWidthConstraint.constant / 2.0
        
        cursor.addGestureRecognizer(panGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if measurePoint == nil {
            let superViewBounds = view.superview!.bounds
            measurePoint = MeasurePoint(xUnit: superViewBounds.width / 2.0,
                                        yUnit: superViewBounds.height / 2.0,
                                        initPosRatio: initPosRatio)
            let pos = view.convert(measurePoint.pos, to: point)
            let pointRadius = pointWidthConstraint.constant / 2.0
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
        let pointRadius = pointWidthConstraint.constant / 2.0
        pos.x += pointRadius
        pos.y += pointRadius
        measurePoint.pos = pos
        
        observers.forEach{ $0.measurePointViewControllerDidMove(self) }
    }
}
