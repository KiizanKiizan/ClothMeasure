//
//  MotionManager.swift
//  BodyMeasure
//
//  Created by 岩井 宏晃 on 2018/06/19.
//  Copyright © 2018年 kiizankiizan. All rights reserved.
//

import Foundation
import CoreMotion

protocol MotionManagerDelegate: class {
    func motionManager(_ motionManager: MotionManager, attitude: CMAttitude)
}

class MotionManager {
    let manager = CMMotionManager()
    var delegate: MotionManagerDelegate?
    
    init() {
        manager.deviceMotionUpdateInterval = 0.2
    }
    
    func start() {
        manager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, error) in
            if let attitude = motion?.attitude {
                self.delegate?.motionManager(self, attitude: attitude)
            }
        }
    }
    
    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}
