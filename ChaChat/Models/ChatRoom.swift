//
//  ChatRoom.swift
//  ChaChat
//
//  Created by sueko14 on 2020/08/16.
//  Copyright © 2020 sueko14. All rights reserved.
//

import Foundation
import Firebase

class Chatroom {
    let latestMessageId: String
    let members: [String]
    let createdAt: Timestamp
    
    var latestMessage: Message?
    var documentId: String?
    var partnerUser: User?
    
    init(dic: [String: Any]){
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.members = dic["members"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}
