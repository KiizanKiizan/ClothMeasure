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
            addMeasurePointViewController(vc: $0.startMeasurePointVc)
            addMeasurePointViewController(vc: $0.endMeasurePointVc)
        }
        didSetup = true
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
