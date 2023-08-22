//
//  ViewController.swift
//  taskapp
//
//  Created by Jo Onishi on 8/13/23.
//

import UIKit
import RealmSwift   //

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    // Realmインスタンスを取得する
        let realm = try! Realm()  // ←追加
    // DB内のタスクが格納されるリスト。
        // 日付の近い順でソート：昇順
        // 以降内容をアップデートするとリスト内は自動的に更新される。
        var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)  // ←追加
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }

       // データの数（＝セルの数）を返すメソッド
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return taskArray.count  // ←修正する

       }

       // 各セルの内容を返すメソッド
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           // 再利用可能な cell を得る
           let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
           // Cellに値を設定する  --- ここから ---
            let task = taskArray[indexPath.row]
            cell.textLabel?.text = task.title

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"

            let dateString:String = formatter.string(from: task.date)
            cell.detailTextLabel?.text = dateString
                  // --- ここまで追加 ---

           return cell
       }

       // 各セルを選択した時に実行されるメソッド
       //tableView(_:didSelectRowAt:)    UITableViewDelegateプロトコルのメソッドで、セルをタップしたときにタスク入力画面に遷移させる
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           performSegue(withIdentifier: "cellSegue",sender: nil) // ←追加する
       }

       // セルが削除が可能なことを伝えるメソッド tableView(_:editingStyleForRowAt:)
       // taskappでは削除を可能にするため、.deleteを返します。
       func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
           return .delete
       }

       // Delete ボタンが押された時に呼ばれるメソッド
       //tableView(_:commit:forRowAt:)
       //UITableViewDataSourceプロトコルのメソッドで、Deleteボタンが押されたときにローカル通知をキャンセルし、データベースからタスクを削除する.
       //後ほどデータベースの実装を行なう際に、ここに追記するのでまずは空のままにしておきます。
       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
                      // データベースから削除する
                      try! realm.write {
                          self.realm.delete(self.taskArray[indexPath.row])
                          tableView.deleteRows(at: [indexPath], with: .fade)
                      }
       }// --- ここまで追加 ---
    }
}
