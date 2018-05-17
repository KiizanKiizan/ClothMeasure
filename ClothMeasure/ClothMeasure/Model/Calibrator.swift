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
    let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
    private let calibrationDistance: Float = 50.0
    
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
                        left = $0.bounds
                    }
                    if $0.messageString == "right" {
                        right = $0.bounds
                    }
                }
                
                if left != nil && right != nil {
                    let leftPos = CGPoint(x: left!.origin.x + left!.width / 2.0, y: left!.origin.y + left!.height / 2.0)
                    let rightPos = CGPoint(x: right!.origin.x + right!.width / 2.0, y: right!.origin.y + right!.height / 2.0)
                    let diffX = Float(leftPos.x) - Float(rightPos.x)
                    let diffY = Float(rightPos.y) - Float(rightPos.y)
                    
                    DispatchQueue.main.async {
                        completion(sqrtf(diffX * diffX + diffY * diffY) / self.calibrationDistance)
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
}
