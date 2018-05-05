//
//  ScanImage.swift
//  ClothScanController
//
//  Created by 岩井 宏晃 on 2018/05/03.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation
import UIKit

class ScanImage {
    private let socketHandler: SocketHandler
    
    var busy: Bool {
        get {
            return socketHandler.busy
        }
    }
    
    init(socketHandler: SocketHandler) {
        self.socketHandler = socketHandler
    }
    
    func scan(completion: @escaping (UIImage?, Data?, SocketError?) -> Void) {
        let imageScanRequest = ImageScanRequest()
        socketHandler.exec(request: imageScanRequest) { (error) in
            if error != nil {
                completion(nil, nil, error)
            } else {
                if let image = imageScanRequest.image, let imageData = imageScanRequest.imageData {
                    completion(image, imageData, nil)
                } else {
                    completion(nil, nil, .notFetchedImage)
                }
            }
        }
    }
}
