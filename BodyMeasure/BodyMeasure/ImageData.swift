//
//  ImageData.swift
//  BodyMeasure
//
//  Created by 岩井 宏晃 on 2018/06/04.
//  Copyright © 2018年 kiizankiizan. All rights reserved.
//

import Foundation
import RealmSwift

class ImageData: Object {
    
    @objc dynamic var id = UUID().uuidString
    var frontImage: Data? {
        get {
            return frontImageData
        }
        set {
            let realm = try! Realm()
            try! realm.write{ frontImageData = newValue }
        }
    }
    @objc private dynamic var frontImageData: Data?
    var sideImage: Data? {
        get {
            return sideImageData
        }
        set {
            let realm = try! Realm()
            try! realm.write{ sideImageData = newValue }
        }
    }
    @objc private dynamic var sideImageData: Data?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func save() {
        let realm = try! Realm()
        try! realm.write{ realm.add(self) }
    }
    
    class func all() -> [ImageData] {
        let realm = try! Realm()
        return realm.objects(ImageData.self).map { $0 }
    }
}
