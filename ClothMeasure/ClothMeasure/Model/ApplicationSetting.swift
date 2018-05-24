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
    
    private static let keyCentimeterPerPoint = "keyCentimeterPerPoint"
    
    init() {
        userDefault.register(defaults: [ApplicationSetting.keyCentimeterPerPoint : Float(1.0)])
    }
    
    func saveCentimeterPerPoint(_ centimeterPerPoint: Float) {
        userDefault.set(centimeterPerPoint, forKey: ApplicationSetting.keyCentimeterPerPoint)
    }
    
    func centimeterPerPoint() -> Float {
        return userDefault.float(forKey: ApplicationSetting.keyCentimeterPerPoint)
    }
}
