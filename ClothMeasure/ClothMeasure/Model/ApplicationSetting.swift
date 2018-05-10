//
//  ApplicationSetting.swift
//  ClothMeasure
//
//  Created by 岩井 宏晃 on 2018/05/11.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

class ApplicationSetting {
    
    let userDefault = UserDefaults.standard
    
    private static let keyPointPerCentimeter = "keyPointPerCentimeter"
    
    func savePointPerCentimeter(_ pointPerCentimeter: Float) {
        userDefault.set(pointPerCentimeter, forKey: ApplicationSetting.keyPointPerCentimeter)
    }
    
    func pointPerCentimeter() -> Float {
        return userDefault.float(forKey: ApplicationSetting.keyPointPerCentimeter)
    }
}
