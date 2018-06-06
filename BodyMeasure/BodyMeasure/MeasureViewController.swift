//
//  MeasureViewController.swift
//  BodyMeasure
//
//  Created by 岩井 宏晃 on 2018/06/06.
//  Copyright © 2018年 kiizankiizan. All rights reserved.
//

import UIKit

class MeasureViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var menuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var pointContainer: UIView!
    
    private var imageRatioConstraint: NSLayoutConstraint?
    
    private var frontImage: UIImage?
    private var sideImage: UIImage?
    
    private var pointPairs = [MeasurePointPair]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapView(gesture:)))
        view.addGestureRecognizer(gesture)
        
        pointPairs.append(MeasurePointPair(type: .chest, points: [CGPoint(x: 100.0, y: 300.0), CGPoint(x: 200.0, y: 300.0)]))
        pointPairs.forEach {
            $0.pointViews.forEach {
                self.pointContainer.addSubview($0)
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
        }
        if image != nil {
            imageRatioConstraint = NSLayoutConstraint(
                item: imageView,
                attribute:NSLayoutAttribute.height,
                relatedBy:NSLayoutRelation.equal,
                toItem: imageView,
                attribute: NSLayoutAttribute.width,
                multiplier: (image!.size.height) / (image!.size.width),
                constant:0)
            imageView.addConstraint(imageRatioConstraint!)
        }
        
        imageView.image = image
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
    
    @IBAction func pushShowFrontImage(_ sender: Any) {
        showImage(frontImage)
    }
    
    @IBAction func pushShowSideImage(_ sender: Any) {
        showImage(sideImage)
    }
    
    @IBAction func pushShowSize(_ sender: Any) {
    }
}
