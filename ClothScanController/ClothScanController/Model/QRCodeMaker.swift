//
//  QRCodeMaker.swift
//  ClothScanController
//
//  Created by 岩井宏晃 on 2018/05/02.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation
import UIKit

class QRCodeMaker {
    class func creatQRCode(text: String) -> UIImage {
        let data = text.data(using: .utf8)!
        let qr = CIFilter(name: "CIQRCodeGenerator", withInputParameters: ["inputMessage": data, "inputCorrectionLevel": "M"])!
        let sizeTransform = CGAffineTransform(scaleX: 10.0, y: 10.0)
        return UIImage(ciImage: qr.outputImage!.transformed(by: sizeTransform))
    }
}
