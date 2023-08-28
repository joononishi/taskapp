import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var categoryTextField: UITextField!///課題の応答　タスク作成画面でcategoryを入力する
    @IBOutlet var datePicker: UIDatePicker!
    var category: String?///課題の応答　タスク作成画面でcategoryを入力できるようにしてください
    let realm = try! Realm()
    var task: Task!
    
    @IBAction func saveButtonTapped(_ sender: Any) {
            let newTask = Task()
        newTask.title = titleTextField.text ?? ""
        newTask.contents = contentsTextView.text//TextViewのtextプロパティだけnilにならないので??はいらない。
        newTask.category = categoryTextField.text ?? "" // 課題の応答 ここを追加

        do {
                try realm.write {
                    realm.add(newTask)
                    setNotification(task: newTask)
                }
            } catch {
                print("Error saving new task: \(error)")
            }
            navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
            super.viewDidLoad()
        
        
        //課題の応答　タスク作成画面でcategoryを入力する
        ///categoryTextFieldからテキストを取得するため、次のコードを使用
        category = titleTextField.text
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
               let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
               self.view.addGestureRecognizer(tapGesture)
               titleTextField.text = task.title
               contentsTextView.text = task.contents
               datePicker.date = task.date
    }
    override func viewWillDisappear(_ animated: Bool) {
        do {
            try realm.write {
                self.task.title = self.titleTextField.text ?? ""
                self.task.contents = self.contentsTextView.text
                self.task.date = self.datePicker.date
                self.realm.add(self.task, update: .modified)
            }
        } catch {
            print("Error updating task: \(error)")
        }
    super.viewWillDisappear(animated)
        }
    @objc func dismissKeyboard(){
               // キーボードを閉じる
        view.endEditing(true)
    }
    // タスクのローカル通知を登録する --- ここから ---
       func setNotification(task: Task) {
           let content = UNMutableNotificationContent()
           // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
           if task.title == "" {
               content.title = "(タイトルなし)"
           } else {
               content.title = task.title
           }
           if task.contents == "" {
               content.body = "(内容なし)"
           } else {
               content.body = task.contents
           }
           content.sound = UNNotificationSound.default

           // ローカル通知が発動するtrigger（日付マッチ）を作成
           let calendar = Calendar.current
           let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
           let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

           // identifier,content,triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
           let request = UNNotificationRequest(identifier: String(task.id.stringValue), content: content, trigger: trigger)
           // ローカル通知を登録
           let center = UNUserNotificationCenter.current()
           center.add(request) { (error) in
               print(error ?? "ローカル通知登録 OK")
               // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
           }
           // 未通知のローカル通知一覧をログ出力
           center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
               for request in requests {
                   print("/---------------")
                   print(request)
                   print("---------------/")
               }
           }
           }
           }
