//
//  Post+Ops.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/03/02.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation
import TypetalkKit


public func +(lhs: Post, rhs: Like) -> Post {
    var likes = lhs.likes
    likes.append(rhs)
    return Post(id: lhs.id, topicId: lhs.topicId, topic: lhs.topic, replyTo: lhs.replyTo, message: lhs.message, account: lhs.account,  attachments: lhs.attachments, likes: likes, talks: lhs.talks, links: lhs.links, createdAt: lhs.createdAt, updatedAt: lhs.updatedAt)
}

public func -(lhs: Post, rhs: Like) -> Post {
    var likes = lhs.likes
    for i in 0..<likes.count {
        if likes[i].id == rhs.id {
            likes.removeAtIndex(i)
            break
        }
    }

    return Post(id: lhs.id, topicId: lhs.topicId, topic: lhs.topic, replyTo: lhs.replyTo, message: lhs.message, account: lhs.account, attachments: lhs.attachments, likes: likes, talks: lhs.talks, links: lhs.links, createdAt: lhs.createdAt, updatedAt: lhs.updatedAt)
}
