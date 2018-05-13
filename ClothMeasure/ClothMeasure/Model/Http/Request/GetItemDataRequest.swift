//
//  GetItemDataRequest.swift
//  ClothMeasure
//
//  Created by 岩井 宏晃 on 2018/05/13.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

class GetItemDataRequest: HttpRequest {
    typealias Response = GetItemDataResponse
    
    func url() -> String {
        return ""
    }
    
    func parameters() -> [String : Any] {
        return [:]
    }
    
    func createResponse(apiResponse: [String : Any]) -> GetItemDataRequest.Response {
        return GetItemDataResponse()
    }
}
