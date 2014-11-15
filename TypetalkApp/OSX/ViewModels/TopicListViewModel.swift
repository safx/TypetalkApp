//
//  TopicListViewModel.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/02.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Cocoa
import TypetalkKit
import ReactiveCocoa
import LlamaKit

class TopicListViewModel : NSObject, NSTableViewDataSource {
    private let model = TopicsDataSource()

    var topics: ObservableArray<TopicWithUserInfo> {
        return model.topics
    }

    func fetch() -> TopicsDataSource.Signal {
        return model.fetch(observe: true)
    }

    // MARK: - NSTableViewDataSource

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return model.topics.count
    }

    // MARK: - ViewModel Actions

    func createTopic(topicName: String) -> ColdSignal<Client.CreateTopicResponse> {
        return model.createTopic(topicName)
    }

    func favoriteTopic(topicId: TopicID) -> ColdSignal<Client.FavoriteTopicResponse> {
        return model.favoriteTopic(topicId)
    }

    func unfavoriteTopic(topicId: TopicID) -> ColdSignal<Client.UnfavoriteTopicResponse> {
        return model.unfavoriteTopic(topicId)
    }
}
