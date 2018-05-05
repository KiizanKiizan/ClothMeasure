//
//  FetchImage.swift
//  ClothMeasure
//
//  Created by 岩井 宏晃 on 2018/05/04.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

import UIKit

class FetchImage {
    private let socketHandler: SocketHandler
    
    var busy: Bool {
        get {
            return socketHandler.busy
        }
    }
    
    init(socketHandler: SocketHandler) {
        self.socketHandler = socketHandler
    }
    
    func fetch(completion: @escaping (UIImage?, SocketError?) -> Void) {
        let fetchImageRequest = FetchImageRequest()
        socketHandler.exec(request: fetchImageRequest) { (error) in
            if error != nil {
                completion(nil, error)
            } else {
                if let image = fetchImageRequest.image {
                    completion(image, nil)
                } else {
                    completion(nil, .notFetchedImage)
                }
            }
        }
    }
}
