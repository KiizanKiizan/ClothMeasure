//
//  MeasureViewController.swift
//  BodyMeasure
//
//  Created by 岩井 宏晃 on 2018/06/06.
//  Copyright © 2018年 kiizankiizan. All rights reserved.
//

import UIKit

class MeasureViewController: UIViewController, MeasurePointPairDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var menuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var pointContainer: UIView!
    @IBOutlet weak var leftZoomView: MeasureZoomView!
    @IBOutlet weak var calibrationSelectControl: UISegmentedControl!
    
    private var imageRatioConstraint: NSLayoutConstraint?
    
    private var frontImage: UIImage?
    private var sideImage: UIImage?
    
    private var pointPairs = [MeasurePointPair]()
    
    private var calibratorQr: CalibratorQR?
    
    private var updateImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapView(gesture:)))
        gesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(gesture)
        
        pointPairs.append(MeasurePointPair(type: .chest, points: [CGPoint(x: 100.0, y: 300.0), CGPoint(x: 200.0, y: 300.0)]))
        pointPairs.forEach {
            $0.delegate = self
            $0.pointViews.forEach {
                self.pointContainer.addSubview($0)
            }
            self.pointContainer.layer.addSublayer($0.shapeLayer)
        }
        
        leftZoomView.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if updateImage {
            updateImage = false
            leftZoomView.setImageSize(pointContainer.bounds.size)
            if calibrationSelectControl.selectedSegmentIndex == 0 {
                let calibrator = CalibratorQR(image: imageView.image, imageViewSize: imageView.bounds.size)
                pointContainer.layer.addSublayer(calibrator.shapeLayer)
                calibrator.calibration()
                calibratorQr = calibrator
            } else {
                
            }
        }
    }
    
    func updateImage(frontImage: UIImage?, sideImage: UIImage?) {
        self.frontImage = frontImage
        self.sideImage = sideImage
        
        showImage(frontImage)
    }
    
    private func showImage(_ image: UIImage?) {
        if imageRatioConstraint != nil {
            imageView.removeConstraint(imageRatioConstraint!)
            imageView.layoutIfNeeded()
        }
        
        calibratorQr = nil
        if image != nil {
            updateImage = true
            imageRatioConstraint = NSLayoutConstraint(
                item: imageView,
                attribute:NSLayoutAttribute.height,
                relatedBy:NSLayoutRelation.equal,
                toItem: imageView,
                attribute: NSLayoutAttribute.width,
                multiplier: (image!.size.height) / (image!.size.width),
                constant:0)
            imageView.addConstraint(imageRatioConstraint!)
            imageView.layoutIfNeeded()
        }
        
        imageView.image = image
        leftZoomView.setImage(image)
    }
    
    @objc func tapView(gesture: UITapGestureRecognizer) {
        let hidden = menuBottomConstraint.constant == 0
        UIView.animate(withDuration: 0.3,
                       animations: {
                        if hidden {
                            self.menuBottomConstraint.constant = self.menuBottomConstraint.constant + self.menuHeightConstraint.constant
                        } else {
                            self.menuBottomConstraint.constant = 0
                        }
                        self.view.layoutIfNeeded()
        }) { (result) in
        }
    }
    
    func measurePointPair(_ controller: MeasurePointPair, DidSelectPointView selectedView: MeasurePointView) {
        leftZoomView.setPointViewColor(selectedView.color)
        leftZoomView.setImagePos(selectedView.center)
        leftZoomView.isHidden = false
    }
    
    func measurePointPair(_ controller: MeasurePointPair, DidDeselectPointView deselectedView: MeasurePointView) {
        leftZoomView.isHidden = true
    }
    
    func measurePointPair(_ controller: MeasurePointPair, SelectedViewDidMove pos: CGPoint) {
        leftZoomView.setImagePos(pos)
    }
    
    @IBAction func pushShowFrontImage(_ sender: Any) {
        showImage(frontImage)
    }
    
    @IBAction func pushShowSideImage(_ sender: Any) {
        showImage(sideImage)
    }
    
    @IBAction func pushShowSize(_ sender: Any) {
        
    }
}
