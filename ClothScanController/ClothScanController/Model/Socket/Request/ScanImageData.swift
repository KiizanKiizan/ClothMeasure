//
//  ScanImageData.swift
//  ClothScanController
//
//  Created by 岩井 宏晃 on 2018/04/30.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation
import UIKit

class ScanImageData {
    let barcodeNumber: String
    var frontImage: UIImage?
    var backImage: UIImage?
    
    init(barcodeNumber: String) {
        self.barcodeNumber = barcodeNumber
    }
}
