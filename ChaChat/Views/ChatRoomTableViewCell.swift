//
//  ChatRoomTableViewCell.swift
//  ChaChat
//
//  Created by sueko14 on 2020/08/15.
//  Copyright © 2020 sueko14. All rights reserved.
//

import UIKit

class ChatRoomTableViewCell : UITableViewCell{
    
    var messageText: String? {
        didSet {
            guard let text = messageText else { return }
            let width = estimateFrameForTextView(text: text).width + 15
            
            messageTextViewWithConstraint.constant = width
            messageTextView.text = text
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var messageTextViewWithConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        userImageView.layer.cornerRadius = 30 //画像を丸くする
        messageTextView.layer.cornerRadius = 15 //文字吹き出しの角を丸くする
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // メッセージの横幅をコンテンツ幅に調整する
    private func estimateFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width:200,height:1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        // UIFont.systemFont(ofSize)には、メッセージテキストビューのサイズを入力する
        return NSString(string: text).boundingRect(with:size,options: options, attributes:[NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
    }
}
