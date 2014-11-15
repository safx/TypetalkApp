//
//  MessageListViewModel.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/02.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation
import TypetalkKit
import ReactiveCocoa
import LlamaKit

class MessageListViewModel : NSObject, NSTableViewDataSource {
    private let model = MessagesDataSource()
    var posts: ObservableArray<Post> {
        return model.posts
    }
    var bookmarkIndex: ObservableProperty<Int> {
        return model.bookmarkIndex
    }

    func fetch(topicId: TopicID) {
        model.fetch(topicId)
    }
    
    func fetchMore(topicId: TopicID) {
        if model.hasNext.value {
            model.hasNext.value = false // TODO
            model.fetchMore(topicId)
        }
    }
    
    // MARK: - NSTableViewDataSource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return model.posts.count
    }

   // MARK: client

    func postMessage(message: String) -> ColdSignal<PostMessageResponse> {
        return model.postMessage(message)
    }

}
