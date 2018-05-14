//
//  GetItemDataResponse.swift
//  ClothMeasure
//
//  Created by 岩井 宏晃 on 2018/05/14.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import Foundation

class GetItemDataResponse {
    private(set) var items = [Item]()
    
    init(ids: [String]) {
        ids.forEach { items.append(Item(id: $0)) }
    }
}
