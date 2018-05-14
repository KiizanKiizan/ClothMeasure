//
//  HttpClient.swift
//  ClothMeasure
//
//  Created by 岩井 宏晃 on 2018/05/13.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

class HttpClient<T: HttpRequest> {
    let request: T
    
    init(request: T) {
        self.request = request
    }
    
    func exec(completion: ((T, Error?) -> Void)?) {
        // TODO: 要実装
        DispatchQueue.main.async {
            self.request.createResponse(apiResponse: [:])
            completion?(self.request, nil)
        }
    }
}
