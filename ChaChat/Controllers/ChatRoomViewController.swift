//
//  ChatRoomViewController.swift
//  ChaChat
//
//  Created by sueko14 on 2020/08/15.
//  Copyright © 2020 sueko14. All rights reserved.
//

import UIKit
import Firebase

class ChatRoomViewController: UIViewController{
    
    var chatroom: Chatroom?
    var user: User?
    
    private let cellId = "cellId"
    private var messages = [Message]()
    
    // inputAccessoryViewのインスタンスを作成
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self //ChatInputAccessoryViewクラスで設定したdelegateプロパティ
        return view
    }()
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        
        // autoLayoutの制約下でも、ちょっと微調整してくれる
        chatRoomTableView.contentInset = .init(top: 0, left: 0, bottom: 40, right: 0)
        chatRoomTableView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 40, right: 0)
        chatRoomTableView.keyboardDismissMode = .interactive //スクロールしたらキーボード閉じる
        fetchMessages()
    }
    
    // ViewControllerのinputAccessoryViewプロパティに、chatInputAccessoryViewを当てはめる
    // inputAccessoryViewを使うと、キーボード表示時にキーボード分の上下スクロールを自動的に補完してくれる
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func fetchMessages(){
        guard let chatroomDocId = chatroom?.documentId else { return }
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").addSnapshotListener { (snapshots, err) in
            if let err = err {
                print("メッセージ情報の取得に失敗しました。\(err)")
            }
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type{
                case .added:
                    let dic = documentChange.document.data()
                    let message = Message(dic: dic)
                    message.partnerUser = self.chatroom?.partnerUser
                    
                    self.messages.append(message)
                    // メッセージの並び替え
                    self.messages.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date < m2Date
                    }
                    
                    // 一番下までスクロールする
                    self.chatRoomTableView.reloadData()
                    self.chatRoomTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: false)
                    
                case .modified, .removed:
                    print("nothing to do")
                }
            })
        }
    }
}

extension ChatRoomViewController: ChatInputAccessoryViewDelegate{
    func tappedSendButton(text: String) {
        addMessageToFirestore(text: text)
    }
    
    private func addMessageToFirestore(text: String){
        guard let chatroomDocId = chatroom?.documentId else { return }
        guard let username = user?.username else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        chatInputAccessoryView.removeText() //無事受け取ったので、文字列を空にする
        let messageId = randomString(length:20)
        
        let docData = [
            "username": username,
            "createdAt": Timestamp(),
            "uid": uid,
            "message": text
            ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId)
            .collection("messages").document(messageId).setData(docData) { (err) in
                if let err = err {
                    print("メッセージ情報の保存に失敗しました。\(err)")
                    return
                }
                
                let latestMessageData = [
                    "latestMessageId": messageId
                ]
                
                // latestMessageIdをセットする
                Firestore.firestore().collection("chatRooms").document(chatroomDocId).updateData(latestMessageData){(err) in
                    if let err = err {
                        print ("最新メッセージの保存に失敗しました。\(err)")
                    }
                }
        }
    }
    // messageIdを自動生成する
    func randomString(length: Int) -> String {
            let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let len = UInt32(letters.length)

            var randomString = ""
        for _ in 0 ..< length {
                let rand = arc4random_uniform(len)
                var nextChar = letters.character(at: Int(rand))
                randomString += NSString(characters: &nextChar, length: 1) as String
            }
            return randomString
    }
}

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20 // セルの最低の長さ
        return UITableView.automaticDimension // メッセージテキストビューの長さに合わせてセルの高さを変える
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ChatRoomTableViewCell
        cell.message = messages[indexPath.row]
        return cell
    }
}
