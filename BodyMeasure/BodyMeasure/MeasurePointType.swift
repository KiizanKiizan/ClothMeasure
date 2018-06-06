//
//  MeasurePointType.swift
//  BodyMeasure
//
//  Created by 岩井 宏晃 on 2018/06/06.
//  Copyright © 2018年 kiizankiizan. All rights reserved.
//

import Foundation
import UIKit

enum MeasurePointType {
    case chest
    
    func color() -> UIColor {
        switch self {
        case .chest:
            return UIColor.red
        }
    }
}
