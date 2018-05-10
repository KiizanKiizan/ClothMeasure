//
//  MeasureViewController.swift
//  ClothMeasure
//
//  Created by 岩井 宏晃 on 2018/05/06.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit

class MeasureViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contentsView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var measurePointPairs = [MeasurePointPair]()
    private(set) var didSetup = false
    
    class func createViewController(measurePointPairs: [MeasurePointPair]) -> MeasureViewController {
        let vc = UIStoryboard(name: "MeasureViewController", bundle: nil).instantiateInitialViewController() as! MeasureViewController
        
        vc.measurePointPairs = measurePointPairs
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
    }
    
    func setup() {
        if didSetup {
            return
        }
        
        measurePointPairs.forEach {
            let shapeLayer = CAShapeLayer()
            let color = UIColor.red.withAlphaComponent(0.3).cgColor
            shapeLayer.strokeColor = color
            shapeLayer.lineWidth = 4.0
            shapeLayer.fillColor = color
            contentsView.layer.addSublayer(shapeLayer)
            $0.shapeLayer = shapeLayer
            
            if $0.startMeasurePointVc != nil {
                addMeasurePointViewController(vc: $0.startMeasurePointVc!)
                scrollView.panGestureRecognizer.require(toFail: $0.startMeasurePointVc!.panGesture)
            }
            if $0.endMeasurePointVc != nil {
                addMeasurePointViewController(vc: $0.endMeasurePointVc!)
                scrollView.panGestureRecognizer.require(toFail: $0.endMeasurePointVc!.panGesture)
            }
        }
        didSetup = true
    }
    
    func setImage(_ image: UIImage?) {
        imageView?.image = image
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentsView
    }
    
    private func addMeasurePointViewController(vc: MeasurePointViewController) {
        contentsView.addSubview(vc.view)
        addChildViewController(vc)
        vc.didMove(toParentViewController: self)
    }
}
