//
//  CategoryInputViewController.swift
//  taskapp
//
//  Created by yosi on 2018/01/29.
//  Copyright © 2018年 mydmers. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications    // 追加[

    class CategoryInputViewController: UIViewController {
        
        @IBOutlet weak var categoryField: UITextField!
        
        let realm = try! Realm()
        var category:Category!
        var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false)  // ←追加
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
            let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
            self.view.addGestureRecognizer(tapGesture)
            
            categoryField.text = category.name
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            try! realm.write {
                self.category.name = self.categoryField.text!
                self.realm.add(self.category, update: true)
            }
            
            super.viewWillDisappear(animated)
        }
        
        func dismissKeyboard(){
            // キーボードを閉じる
            view.endEditing(true)
        }
        
        
/*        //UIPickerViewDataSource
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            //表示する列数
            return 1
        }
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            //表示個数を返す
            return categoryArray.count
        } */
        
        
/*        // segue で画面遷移するに呼ばれる
        override func prepare(for segue: UIStoryboardSegue, sender: Any?){
            let categoryViewController:CategoryViewController = segue.destination as! CategoryViewController
            
            if segue.identifier == "cellSegue" {
                let indexPath = categoryViewController.tableview2.indexPathForSelectedRow
                categoryViewController.category = categoryArray[indexPath!.row]
            } else {
                let category = Category()
                
                if categoryArray.count != 0 {
                    category.id = categoryArray.max(ofProperty: "id")! + 1
                }
                
                categoryViewController.category = category
            }
        }*/
        
    }

    
    
//--------------------

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
