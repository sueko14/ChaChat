//
//  ChatListViewController.swift
//  ChaChat
//
//  Created by sueko14 on 2020/08/14.
//  Copyright © 2020 sueko14. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController{
    
    private let cellId = "cellId"
    @IBOutlet weak var chatListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39,green:49,blue:69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // チャットリストの画面からSignUpの画面を表示する
        let storyboard = UIStoryboard(name:"SignUp", bundle:nil)
        let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController")
        self.present(signUpViewController, animated: true, completion: nil)
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
        return 10
    }
    // Cellに表示する情報
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
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
}

