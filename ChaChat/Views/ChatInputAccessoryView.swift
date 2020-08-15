//
//  ChatInputAccessoryView.swift
//  ChaChat
//
//  Created by sueko14 on 2020/08/15.
//  Copyright © 2020 sueko14. All rights reserved.
//

import UIKit

// Delegateの作った手順
// 1. ChatInputAccessoryViewDelegate protocolを作る
// 2. ChatInputAccessoryViewの中にdelegateプロパティを作る
// 3. ChatInputAccessoryViewDelegateクラスで作ったメソッドをChatInputAccessoryViewで実装する
// 4. ChatRoomViewController内で生成しているChatInputAccessoryViewインスタンスでdelegateをselfにする
// 5. delegateをextensionで作成して、delegateクラスで作成した関数を定義する
// 6. lazy

// sendButtonが押された時に入力内容をviewControllerに渡すためにDelegateを作成する
protocol ChatInputAccessoryViewDelegate: class {
    func tappedSendButton(text:String) //送りたい情報
}

class ChatInputAccessoryView: UIView {
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func tappedSendButton(_ sender: Any) {
        guard let text = chatTextView.text else{ return }
        delegate?.tappedSendButton(text: text)
    }
    
    weak var delegate: ChatInputAccessoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        nibInit()
        setupViews()
        autoresizingMask = .flexibleHeight //コンテンツのサイズに応じて、入力内容を上に上がるように修正
    }
    
    private func setupViews(){
        
        chatTextView.layer.cornerRadius = 15
        chatTextView.layer.borderColor = UIColor.rgb(red: 230, green: 230, blue: 230).cgColor
        chatTextView.layer.borderWidth = 1
        sendButton.layer.cornerRadius = 15
        sendButton.imageView?.contentMode = .scaleAspectFill
        sendButton.contentHorizontalAlignment = .fill
        sendButton.contentVerticalAlignment = .fill
        sendButton.isEnabled = false
        
        chatTextView.text = "" //初期文字列をなくす
        chatTextView.delegate = self //入力している文字列を監視する
    }
    
    func removeText(){
        chatTextView.text = ""
        sendButton.isEnabled = false
    }
    
    //コンテンツのサイズに応じてサイズを自動的に変更させる
    override var intrinsicContentSize: CGSize{
        return .zero
    }
    // xibファイルを紐付け
    private func nibInit(){
        let nib = UINib(nibName: "ChatInputAccessoryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChatInputAccessoryView: UITextViewDelegate{
    //テキストビューがどう変更されたかを確認できる
    func textViewDidChange(_ textView: UITextView) {
        // print("ChatInputAccessoryView textViewDidChange:" ,textView.text)
        if textView.text.isEmpty{
            sendButton.isEnabled = false
        }else{
            sendButton.isEnabled = true
        }
    }
}
