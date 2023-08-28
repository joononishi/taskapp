import UIKit
import RealmSwift   //
import UserNotifications
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField! // 検索用のテキストフィールド これはいらないのかもだが、これを消すとsearchTextfieldのあたりに支障が出る。
    let realm = try! Realm()
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let inputViewController: InputViewController = segue.destination as! InputViewController
            if segue.identifier == "cellSegue" {
                let indexPath = self.tableView.indexPathForSelectedRow
                inputViewController.task = taskArray[indexPath!.row]
            } else {
                inputViewController.task = Task()
            }
        }
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            tableView.reloadData()
        }
        
        @IBAction func searchButtonTapped(_ sender: Any) {
            let filterString = searchTextField.text ?? ""
            taskArray = realm.objects(Task.self).filter("category == %@", filterString).sorted(byKeyPath: "date", ascending: true)
            tableView.reloadData()
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return taskArray.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let task = taskArray[indexPath.row]
            cell.textLabel?.text = task.title
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let dateString: String = formatter.string(from: task.date)
            cell.detailTextLabel?.text = "\(dateString) | \(task.category)"//ここに課題のカテゴリーを入力させる
            return cell
        }
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id.stringValue)]) // ここでカッコを閉じています
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "cellSegue", sender: nil)
        }
        
        func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
            return .delete
    }
}

