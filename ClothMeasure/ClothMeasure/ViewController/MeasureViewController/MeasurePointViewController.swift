//
//  MeasurePointViewController.swift
//  ClothMeasure
//
//  Created by 岩井 宏晃 on 2018/05/07.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit

protocol MeasurePointViewControllerDelegate: class {
    func measurePointViewControllerDidMove(_ vc: MeasurePointViewController)
}

class MeasurePointViewController: UIViewController {

    @IBOutlet weak var cursor: UIImageView!
    @IBOutlet weak var point: UIView!
    @IBOutlet weak var pointWidthConstraint: NSLayoutConstraint!
    
    weak var delegate: MeasurePointViewControllerDelegate?
    
    private(set) var measurePoint: MeasurePoint!
    
    class func createViewController(measurePoint: MeasurePoint) -> MeasurePointViewController {
        let vc = UIStoryboard(name: "MeasurePointViewController", bundle: nil).instantiateInitialViewController() as! MeasurePointViewController
        vc.measurePoint = measurePoint
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = CGRect(x: 0.0,
                            y: 0.0,
                            width: preferredContentSize.width,
                            height: preferredContentSize.height)

        point.layer.cornerRadius = pointWidthConstraint.constant / 2.0
        
        cursor.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panCursor)))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let pos = view.convert(measurePoint.pos, from: point)
        view.frame = CGRect(x: pos.x,
                            y: pos.y,
                            width: view.bounds.width,
                            height: view.bounds.height)
    }

    @objc func panCursor(sender: UIPanGestureRecognizer) {
        let move = sender.translation(in: view)
        sender.setTranslation(.zero, in: view)
        view.frame = CGRect(x: view.frame.origin.x + move.x,
                            y: view.frame.origin.y + move.y,
                            width: view.bounds.width,
                            height: view.bounds.height)
        let pos = point.convert(point.frame.origin, to: view)
        measurePoint.pos = pos
        
        delegate?.measurePointViewControllerDidMove(self)
    }
}
