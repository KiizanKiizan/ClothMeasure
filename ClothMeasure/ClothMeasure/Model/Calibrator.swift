//
//  Calibrator.swift
//  ClothMeasure
//
//  Created by 岩井宏晃 on 2018/05/17.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation
import UIKit

class Calibrator {
    let scale: CGFloat
    let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
    private let calibrationDistance: Float = 40.0
    
    init(scale: CGFloat) {
        self.scale = scale
    }
    
    func calibration(image: UIImage, completion: @escaping (Float?) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            completion(nil)
            return
        }
        DispatchQueue.global().async {
            if let features = self.detector?.features(in: ciImage) as? [CIQRCodeFeature] {
                var left: CGRect?
                var right: CGRect?
                features.forEach {
                    if $0.messageString == "left" {
                        left = self.boundsWithScale(bounds: $0.bounds)
                    }
                    if $0.messageString == "right" {
                        right = self.boundsWithScale(bounds: $0.bounds)
                    }
                }
                
                if left != nil && right != nil {
                    let leftPos = CGPoint(x: left!.origin.x + left!.width / 2.0, y: left!.origin.y + left!.height / 2.0)
                    let rightPos = CGPoint(x: right!.origin.x + right!.width / 2.0, y: right!.origin.y + right!.height / 2.0)
                    let diffX = Float(leftPos.x) - Float(rightPos.x)
                    let diffY = Float(leftPos.y) - Float(rightPos.y)
                    
                    DispatchQueue.main.async {
                        completion(self.calibrationDistance / sqrtf(diffX * diffX + diffY * diffY))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    private func boundsWithScale(bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x / scale,
                      y: bounds.origin.y / scale,
                      width: bounds.width / scale,
                      height: bounds.height / scale)
    }
}
