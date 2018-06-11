//
//  CalibratorQR.swift
//  BodyMeasure
//
//  Created by 岩井 宏晃 on 2018/06/11.
//  Copyright © 2018年 kiizankiizan. All rights reserved.
//

import Foundation
import UIKit
import Vision

struct QRRect {
    let topLeft: CGPoint
    let topRight: CGPoint
    let bottomLeft: CGPoint
    let bottomRight: CGPoint
}

class CalibratorQR {
    private let qrSize: CGFloat = 20.0
    
    private let imageViewSize: CGSize
    private var image: UIImage?
    
    let shapeLayer = CAShapeLayer()
    
    init(image: UIImage?, imageViewSize: CGSize) {
        self.image = image
        self.imageViewSize = imageViewSize
        
        let color = UIColor.red.withAlphaComponent(0.3).cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 2.0
        shapeLayer.fillColor = color
    }
    
    deinit {
        shapeLayer.removeFromSuperlayer()
    }
    
    func calibration() {
        guard let _image = image else {
            return
        }
        
        let barcodeRequest = VNDetectBarcodesRequest(completionHandler: { request, error in
            self.reportResults(results: request.results)
        })
        let handler = VNImageRequestHandler(cgImage: _image.cgImage!, options: [.properties : ""])
        
        try? handler.perform([barcodeRequest])
    }
    
    private func reportResults(results: [Any]?) {
        guard let results = results else {
            return
        }
        for result in results {
            
            // Cast the result to a barcode-observation
            if let barcode = result as? VNBarcodeObservation {
                
                let width = imageViewSize.width
                let height = imageViewSize.height
                let topLeft = CGPoint(x: barcode.topLeft.y * width, y: barcode.topLeft.x * height)
                let topRight = CGPoint(x: barcode.topRight.y * width, y: barcode.topRight.x * height)
                let bottomRight = CGPoint(x: barcode.bottomRight.y * width, y: barcode.bottomRight.x * height)
                let bottomLeft = CGPoint(x: barcode.bottomLeft.y * width, y: barcode.bottomLeft.x * height)
                
                let qrRect = QRRect(topLeft: topLeft,
                                    topRight: topRight,
                                    bottomLeft: bottomLeft,
                                    bottomRight: bottomRight)
                drawRect(rect: qrRect)
                return
            }
        }
    }
    
    private func drawRect(rect: QRRect) {
        let uiPath = UIBezierPath()
        uiPath.move(to: rect.topLeft)
        uiPath.addLine(to: rect.topRight)
        uiPath.addLine(to: rect.bottomRight)
        uiPath.addLine(to: rect.bottomLeft)
        uiPath.addLine(to: rect.topLeft)
        
        shapeLayer.path = uiPath.cgPath
    }
}
