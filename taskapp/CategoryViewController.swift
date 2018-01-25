//
//  CategoryViewController.swift
//  taskapp
//
//  Created by yosi on 2018/01/23.
//  Copyright © 2018年 mydmers. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UIViewController, UITableViewDelegate, UIPickerViewDataSource, UITableViewDataSource {

    @IBOutlet weak var tableview2: UITableView!
    
    //Realmインスタンスを取得する
    let realm = try! Realm()
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false)
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableview2.delegate = self
        tableview2.dataSource = self
        
        categoryArray = realm.objects(Category.self)
            .sorted(byKeyPath: "id", ascending: false)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView2(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count  // ←追加する
    }

    // 各セルの内容を返すメソッド
    func tableView2(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableview2.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        
        // Cellに値を設定する.
        let category = categoryArray[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView2(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView2(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // 削除されたタスクを取得する
            let category = self.categoryArray[indexPath.row]
            
            // ローカル通知をキャンセルする
//            let center = UNUserNotificationCenter.current()
//  center.removePendingNotificationRequests(withIdentifiers: [String(Category.id)])

            // データベースから削除する
            try! realm.write {
                self.realm.delete(categoryArray)
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
/*            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            } */
        }
    }
    // segue で画面遷移するに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableview2.indexPathForSelectedRow
            inputViewController.categoryArray = categoryArray[indexPath!.row]
        } else {
            let category = Category()
            
            if categoryArray.count != 0 {
                category.id = categoryArray.max(ofProperty: "id")! + 1
            }
            
            inputViewController.categoryArray = category
        }
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
