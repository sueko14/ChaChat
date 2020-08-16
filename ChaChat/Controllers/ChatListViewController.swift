//
//  ChatListViewController.swift
//  ChaChat
//
//  Created by sueko14 on 2020/08/14.
//  Copyright © 2020 sueko14. All rights reserved.
//

import UIKit
import Firebase

class ChatListViewController: UIViewController{
    
    private let cellId = "cellId"
    private var users = [User]()
    @IBOutlet weak var chatListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39,green:49,blue:69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // ログイン情報が端末にない場合
        if Auth.auth().currentUser?.uid == nil {
            // チャットリストの画面からSignUpの画面を表示する
            let storyboard = UIStoryboard(name:"SignUp", bundle:nil)
            let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            signUpViewController.modalPresentationStyle = .fullScreen // フルスクリーンでmodalにする
            self.present(signUpViewController, animated: true, completion: nil)
        }
    }
    
    // ライフサイクルのメソッド。viewDidLoadの後に呼び出される
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserInfoFromFirestore()
    }
    
    private func fetchUserInfoFromFirestore(){
        Firestore.firestore().collection("users").getDocuments{ (snapshots,err) in
            if let err = err {
                print("users情報の取得に失敗しました。\(err)")
                return
            }
            snapshots?.documents.forEach({(snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                
                self.users.append(user)
                self.chatListTableView.reloadData()
                
                self.users.forEach { (user) in
                    print("user.username: \(user.username)")
                }
            })
        }
    }
}

// delegateとdatasourceの処理
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource{
    
    // chatListTableViewCellのセルの高さ指定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    // chatListTableViewの表示数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    // Cellに表示する情報
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTableViewCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    // テーブルビューがタップされた時に呼び出される
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name:"ChatRoom",bundle:nil)
        let chatRoomViewController = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController")
        navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
}

// Cell内にイメージやラベルを設定しているため、セルクラスも作る
class ChatListTableViewCell: UITableViewCell{
    
    var user: User? {
        didSet{
            if let user = user{
            partnerLabel.text = user.username
            //userImageView.image = user?.profileImageUrl
            dateLabel.text = dateFormatterForDatelabel(date: user.createdAt.dateValue())
            latestMessageLabel.text = user.email
            }
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 35 // 丸くするため半分
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func dateFormatterForDatelabel(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

