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
    
    private var didSetup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didSetup {
            let measurePoint = MeasurePoint(type: .calibration,
                                            xUnit: view.bounds.width / 2.0, yUnit: view.bounds.height / 2.0, initPosRatio: CGPoint(x: 0.7, y: 0.8))
            let vc = MeasurePointViewController.createViewController(measurePoint: measurePoint)
            view.addSubview(vc.view)
            addChildViewController(vc)
            vc.didMove(toParentViewController: self)
            didSetup = true
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentsView
    }
}
