//
//  ChatListViewController.swift
//  ChaChat
//
//  Created by sueko14 on 2020/08/14.
//  Copyright © 2020 sueko14. All rights reserved.
//

import UIKit
import Firebase
import Nuke

class ChatListViewController: UIViewController{
    
    private let cellId = "cellId"
    private var chatrooms = [Chatroom]()
    private var chatRoomListener: ListenerRegistration?
    private var user: User? {
        didSet {
            navigationItem.title = user?.username
        }
    }
   

    @IBOutlet weak var chatListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        confirmLoggedInUser()
        fetchChatroomsInfoFromFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLoginUserInfo()
    }
    
    func fetchChatroomsInfoFromFirestore(){
        // 呼ばれるたびにデータをきれいにしてからfirestoreからの取得処理を実行する
        chatRoomListener?.remove()
        chatrooms.removeAll()
        chatListTableView.reloadData()
        
        chatRoomListener = Firestore.firestore().collection("chatRooms")
            .addSnapshotListener { (snapshots, err) in // リアルタイム処理をする
                //.getDocuments { (snapshots, err) in //
                if let err = err {
                    print("chatRoom情報の取得に失敗しました。\(err)")
                }
                snapshots?.documentChanges.forEach({ (documentChange) in
                    switch documentChange.type {
                    case .added:
                        self.handleAddedDocumentChange(documentChange: documentChange)
                    case .modified, .removed:
                        print("nothing to do.")
                    }
                })
        }
    }
    
    private func handleAddedDocumentChange(documentChange: DocumentChange){
        let dic = documentChange.document.data()
        let chatroom = Chatroom(dic: dic)
        chatroom.documentId = documentChange.document.documentID
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let isContain = chatroom.members.contains(uid)
        
        if !isContain { return }
        
        chatroom.members.forEach { (memberUid) in
            if memberUid != uid {
                Firestore.firestore().collection("users").document(memberUid).getDocument { (userSnapshot, err) in
                    if let err = err {
                        print("ユーザー情報の取得に失敗しました。\(err)")
                        return
                    }
                    
                    guard let dic = userSnapshot?.data() else { return }
                    let user = User(dic: dic)
                    user.uid = documentChange.document.documentID
                    chatroom.partnerUser = user
                    
                    guard let chatroomId = chatroom.documentId else { return }
                    let latestMessageId = chatroom.latestMessageId
                   
                    if latestMessageId == "" {
                        self.chatrooms.append(chatroom)
                        self.chatListTableView.reloadData()
                        return
                    }
                    
                    Firestore.firestore().collection("chatRooms").document(chatroomId).collection("messages").document(latestMessageId).getDocument { (messageSnapshot, err) in
                        
                        if let err = err {
                            print("最新情報の取得に失敗しました。\(err)")
                            return
                        }
                        
                        guard let dic = messageSnapshot?.data() else { return }
                        let message = Message(dic: dic)
                        chatroom.latestMessage = message
                        
                        self.chatrooms.append(chatroom)
                        self.chatListTableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func setupViews() {
        chatListTableView.tableFooterView = UIView() // 画面下をきれいにする
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39,green:49,blue:69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let rightBarButton = UIBarButtonItem(title: "新規チャット", style: .plain, target: self, action: #selector(tappedNavRightBarButton))
        let logoutBarButton = UIBarButtonItem(title: "ログアウト", style: .plain , target: self, action: #selector(tappedLogoutButton))
        navigationItem.rightBarButtonItem = rightBarButton //アイテムセットするときはnagivationController.ってする必要ない
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem = logoutBarButton
        navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    @objc private func tappedLogoutButton(){
        do {
            try Auth.auth().signOut()
            pushLoginViewController()
        } catch {
            print("ログアウトに失敗しました。\(error)")
        }
    }
    
    // ログイン情報が端末にない場合、SignUp画面を表示する処理
    private func confirmLoggedInUser(){
        if Auth.auth().currentUser?.uid == nil {
            pushLoginViewController()
        }
    }
    
    private func pushLoginViewController(){
        // チャットリストの画面からSignUpの画面を表示する
        let storyboard = UIStoryboard(name:"SignUp", bundle:nil)
        let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        let nav = UINavigationController(rootViewController: signUpViewController) // signUpViewControllerにはnavigation controllerをつけてない。chatListからつけてあげる
        nav.modalPresentationStyle = .fullScreen // フルスクリーンでmodalにする
        self.present(nav, animated: true, completion: nil)
    }
    
    // 右上のナビゲーションボタン。これを押したらユーザーリストを表示する
    @objc private func tappedNavRightBarButton(){
        let storyboard = UIStoryboard.init(name:"UserList", bundle: nil)
        let userListViewController = storyboard.instantiateViewController(withIdentifier: "UserListViewController")
        let nav = UINavigationController(rootViewController: userListViewController)
        self.present(nav, animated: true, completion: nil)
    }
    
    //ログインしているユーザーの情報の取得
    private func fetchLoginUserInfo(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
            }
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            let user = User(dic: dic)
            self.user = user
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
        return chatrooms.count
    }
    // Cellに表示する情報
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTableViewCell
        cell.chatroom = chatrooms[indexPath.row]
        return cell
    }
    
    // テーブルビューがタップされた時に呼び出される
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name:"ChatRoom",bundle:nil)
        let chatRoomViewController = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController") as! ChatRoomViewController
        chatRoomViewController.chatroom = chatrooms[indexPath.row]
        chatRoomViewController.user = user
        navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
}

// Cell内にイメージやラベルを設定しているため、セルクラスも作る
class ChatListTableViewCell: UITableViewCell{
    
    var chatroom: Chatroom? {
        didSet {
            if let chatroom = chatroom {
                partnerLabel.text = chatroom.partnerUser?.username
                
                guard let url = URL(string: chatroom.partnerUser?.profileImageUrl ?? "") else { return }
                Nuke.loadImage(with: url, into: userImageView)
                
                dateLabel.text = dateFormatterForDatelabel(date: chatroom.latestMessage?.createdAt.dateValue() ?? Date())
                
                latestMessageLabel.text = chatroom.latestMessage?.message
            }
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 30 // 丸くするため半分
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

