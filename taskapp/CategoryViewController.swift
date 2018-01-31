//
//  CategoryViewController.swift
//  taskapp
//
//  Created by yosi on 2018/01/23.
//  Copyright © 2018年 mydmers. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications    // 追加

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview2: UITableView!
    
    //Realmインスタンスを取得する
    let realm = try! Realm()
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false)
    var category:Category!
    var selectedCategory:Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableview2.delegate = self
        tableview2.dataSource = self
        
        categoryArray = realm.objects(Category.self)
            .sorted(byKeyPath: "id", ascending: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count  // ←追加する
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableview2.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        
        // Cellに値を設定する.
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        
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
            let category = self.categoryArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(category.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(category)
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
        
    // segue で画面遷移するに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let categoryInputViewController:CategoryInputViewController = segue.destination as! CategoryInputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableview2.indexPathForSelectedRow
            categoryInputViewController.category = categoryArray[indexPath!.row]
        } else {
            let category = Category()
//            task.date = NSDate()
            
            if categoryArray.count != 0 {
                category.id = categoryArray.max(ofProperty: "id")! + 1
                
                print(category.id)
            }
            
            categoryInputViewController.category = category
        }
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableview2.reloadData()
    }
    
}
