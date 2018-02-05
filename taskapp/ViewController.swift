//
//  ViewController.swift
//  taskapp
//
//  Created by yosi on 2018/01/06.
//  Copyright © 2018年 mydmers. All rights reserved.
//

import UIKit
import RealmSwift // 追加
import UserNotifications    // 追加

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchText2: UITextField!
    
    let realm = try! Realm()
    var task:Task!
    var category:Category!
    var selectedCategory:Int!
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false)  // ←追加
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)  // ←追加
    var pickerView: UIPickerView = UIPickerView()
    var searchText_temp:String!

    let toolbar = UIToolbar()
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped(_:)))
    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped(_:)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        pickerView.delegate = self
        
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true
        toolbar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolbar.sizeToFit()
        toolbar.setItems([cancelButton, space, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        self.searchText2.inputView = pickerView
        self.searchText2.inputAccessoryView = toolbar
        
    }

    //done
    func doneTapped(_ sender:UIBarButtonItem)  {
        self.dismissKeyboard()
        
        searchText_temp = searchText2.text!
        if !searchText_temp.isEmpty {
            // 検索の文字列が空でないとき、フィルタをかける
            let predicate = NSPredicate(format: "category.name contains %@", (searchText_temp)!)
            taskArray = realm.objects(Task.self)
                .filter(predicate)
                .sorted(byKeyPath: "date", ascending: false)
        }
        else {
            // 検索の文字列が空のとき
            taskArray = realm.objects(Task.self)
                .sorted(byKeyPath: "date", ascending: false)
        }
        
        //テーブルを再読み込みする。
        tableView.reloadData()
    }
  
    //cancel
    func cancelTapped(_ sender: UIBarButtonItem) {
        self.dismissKeyboard()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count  // ←追加する
    }

/*
    //検索ボタン押下時の呼び出しメソッド
    func searchBar(_ searchBar: UISearchBar,  textDidChange searchText2: String) {
        
        if !searchText2.isEmpty {
            // 検索の文字列が空でないとき、フィルタをかける
            
            let predicate = NSPredicate(format: "category.name contains %@", (searchText_temp)!)
            taskArray = realm.objects(Task.self)
                .filter(predicate)
                .sorted(byKeyPath: "date", ascending: false)
        }
        else {
            // 検索の文字列が空のとき
            taskArray = realm.objects(Task.self)
                .sorted(byKeyPath: "date", ascending: false)
        }
        
        //テーブルを再読み込みする。
        tableView.reloadData()
    }
 */
 
    func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        
        // Cellに値を設定する.
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString:String = formatter.string(from: task.date as Date)
        cell.detailTextLabel?.text = dateString

        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // 削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
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
    
    //UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //表示する列数
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //表示個数を返す
        return categoryArray.count
    }
    
    //pickerView
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        //表示する文字列を返す
        return categoryArray[row].name
    }
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        //選択時の処理方法
        searchText2.text = categoryArray[row].name
    }

        // segue で画面遷移するに呼ばれる
        override func prepare(for segue: UIStoryboardSegue, sender: Any?){
            let inputViewController:InputViewController = segue.destination as! InputViewController
            
            if segue.identifier == "cellSegue" {
                let indexPath = self.tableView.indexPathForSelectedRow
                inputViewController.task = taskArray[indexPath!.row]
            } else {
                let task = Task()
                task.date = NSDate()
                
                if taskArray.count != 0 {
                    task.id = taskArray.max(ofProperty: "id")! + 1
                }
                
                inputViewController.task = task
            }
        }
    
        // 入力画面から戻ってきた時に TableView を更新させる
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            tableView.reloadData()
        }
    }
