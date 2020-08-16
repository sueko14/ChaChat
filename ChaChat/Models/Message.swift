//
//  Message.swift
//  ChaChat
//
//  Created by sueko14 on 2020/08/16.
//  Copyright © 2020 sueko14. All rights reserved.
//

import Foundation
import Firebase

class Message{
    let username: String
    let uid: String
    let message: String
    let createdAt: Timestamp
    
    var partnerUser: User?
    
    init(dic: [String: Any]) {
        self.username = dic["username"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}
