//
//  InputViewController.swift
//  taskapp
//
//  Created by yosi on 2018/01/06.
//  Copyright © 2018年 mydmers. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications    // 追加

class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryField: UITextField!
    
    let realm = try! Realm()
    var task:Task!
    var category:Category!
    var selectedCategory:Int!
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false)  // ←追加
    var pickerView: UIPickerView = UIPickerView()
    
    let toolbar = UIToolbar()
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped(_:)))
    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped(_:)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        pickerView.delegate = self
 
        //toolbar設定
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true
        toolbar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolbar.sizeToFit()
        toolbar.setItems([cancelButton, space, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        self.categoryField.inputView = pickerView
        self.categoryField.inputAccessoryView = toolbar

        //入力項目（タイトル、カテゴリ、内容、日時）
        titleTextField.text = task.title
        categoryField.text = task.category?.name
        contentsTextView.text = task.contents
        datePicker.date = task.date as Date
        
    }
    
    func doneTapped(_ sender:UIBarButtonItem)  {
        self.dismissKeyboard()
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date as NSDate
            
            selectedCategory = pickerView.selectedRow(inComponent: 0)
            if (self.categoryArray.count > 0) {
                self.task.category = self.categoryArray[pickerView.selectedRow(inComponent: 0)]
                categoryField.text = self.task.category?.name
            }
            self.realm.add(self.task, update: true)
        }
    }
    
    func cancelTapped(_ sender: UIBarButtonItem) {
        self.dismissKeyboard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            if (self.titleTextField.text) == nil {
                self.task.title = self.titleTextField.text!
                self.task.contents = self.contentsTextView.text
                self.task.date = self.datePicker.date as NSDate
                selectedCategory = pickerView.selectedRow(inComponent: 0)
                if (self.categoryArray.count > 0) {
                    self.task.category = self.categoryArray[pickerView.selectedRow(inComponent: 0)]
                    categoryField.text = self.task.category?.name
                }
            }
            else {
                self.task.title = self.titleTextField.text!
                self.task.contents = self.contentsTextView.text
                self.task.date = self.datePicker.date as NSDate
                selectedCategory = pickerView.selectedRow(inComponent: 0)
                if (self.categoryArray.count > 0) {
                    categoryField.text = self.task.category?.name
                }
            }
            self.realm.add(self.task, update: true)
        }
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }
    
    func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    // タスクのローカル通知を登録する
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body  = task.contents       // bodyが空だと音しか出ない
        content.sound = UNNotificationSound.default()
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = NSCalendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date as Date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
            print("ローカル通知登録", self.categoryField)
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
        categoryField.text = categoryArray[row].name
    }
    
    // segue で画面遷移する時に呼ばれる
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
    }

}
