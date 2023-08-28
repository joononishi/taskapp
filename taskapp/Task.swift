//
//  Task.swift
//  taskapp
//
//  Created by Jo Onishi on 8/23/23.
//

import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    @Persisted(primaryKey: true) var id: ObjectId
    
    // タイトル
    @Persisted var title = ""
    
    // 内容
    @Persisted var contents = ""
    
    // 日時
    @Persisted var date = Date()
    
    // カテゴリ　課題の応答　TaskクラスにcategoryというStringプロパティを追加してください
    @Persisted var category = "" // 追加されたプロパティ
}
