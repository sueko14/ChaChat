//
//  ChatRoomTableViewCell.swift
//  ChaChat
//
//  Created by sueko14 on 2020/08/15.
//  Copyright © 2020 sueko14. All rights reserved.
//

import UIKit
import Firebase
import Nuke

class ChatRoomTableViewCell : UITableViewCell{
    
    var message: Message? {
        didSet {
//            if let message = message {
//                partnerMessageTextView.text = message.message
//                let width = estimateFrameForTextView(text: message.message).width + 15
//                messageTextViewWithConstraint.constant = width
//                partnerDateLabel.text = dateFormatterForDatelabel(date: message.createdAt.dateValue())
//            }
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var partnerMessageTextView: UITextView!
    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var partnerDateLabel: UILabel!
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var partnerMessageTextViewWithConstraint: NSLayoutConstraint!
    @IBOutlet weak var myMessageTextViewWithConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        userImageView.layer.cornerRadius = 30 //画像を丸くする
        partnerMessageTextView.layer.cornerRadius = 15 //文字吹き出しの角を丸くする
        myMessageTextView.layer.cornerRadius = 15 //文字吹き出しの角を丸くする
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkWhichUserMessage()
    }
    
    private func checkWhichUserMessage(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if uid == message?.uid {
            // 自分のメッセージなので、相手のメッセージ等は表示しない
            partnerMessageTextView.isHidden = true
            partnerDateLabel.isHidden = true
            userImageView.isHidden = true
            myMessageTextView.isHidden = false
            myDateLabel.isHidden = false
            
            if let message = message {
                myMessageTextView.text = message.message
                let width = estimateFrameForTextView(text: message.message).width + 15
                myMessageTextViewWithConstraint.constant = width
                myDateLabel.text = dateFormatterForDatelabel(date: message.createdAt.dateValue())
            }
            
        } else {
            partnerMessageTextView.isHidden = false
            partnerDateLabel.isHidden = false
            userImageView.isHidden = false
            myMessageTextView.isHidden = true
            myDateLabel.isHidden = true
            if let urlString = message?.partnerUser?.profileImageUrl, let url = URL(string: urlString) {
                Nuke.loadImage(with: url, into: userImageView)
            }
            
            if let message = message {
                partnerMessageTextView.text = message.message
                let width = estimateFrameForTextView(text: message.message).width + 15
                partnerMessageTextViewWithConstraint.constant = width
                partnerDateLabel.text = dateFormatterForDatelabel(date: message.createdAt.dateValue())
            }
        }
    }
    
    // メッセージの横幅をコンテンツ幅に調整する
    private func estimateFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width:200,height:1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        // UIFont.systemFont(ofSize)には、メッセージテキストビューのサイズを入力する
        return NSString(string: text).boundingRect(with:size,options: options, attributes:[NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    private func dateFormatterForDatelabel(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
