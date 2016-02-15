//
//  MessageListViewModel.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/02.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation
import AppKit
import TypetalkKit
import RxSwift
import ObservableArray


class MessageListViewModel : NSObject, NSTableViewDataSource {
    typealias OArray = ObservableArray<Post>
    private let model = MessagesDataSource()

    var posts: OArray {
        return model.posts
    }
    var postsEvent: Observable<OArray.EventType> {
        return model.posts.rx_events()
    }
    var bookmarkIndex: Variable<Int> {
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

    func postMessage(message: String) -> Observable<PostMessageResponse> {
        return model.postMessage(message)
    }

}
