//
//  Category.swift
//  taskapp
//
//  Created by yosi on 2018/01/20.
//  Copyright © 2018年 mydmers. All rights reserved.
//

import UIKit
import RealmSwift

class Category: Object {
    // 管理用 ID。プライマリーキー
    dynamic var id = 0
    
    // カテゴリ
    dynamic var name: String = ""
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}
