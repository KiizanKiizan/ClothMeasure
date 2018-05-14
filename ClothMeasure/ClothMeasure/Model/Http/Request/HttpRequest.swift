//
//  HttpRequest.swift
//  ClothMeasure
//
//  Created by 岩井 宏晃 on 2018/05/13.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

protocol HttpRequest {
    associatedtype Response
    func url() -> String
    func parameters() -> [String : Any]
    func createResponse(apiResponse: [String : Any])
    func response() -> Response
}
