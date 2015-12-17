//
//  TopicListViewModel.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/02.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Cocoa
import TypetalkKit
import RxSwift


class TopicListViewModel : NSObject, NSTableViewDataSource {
    private let model = TopicsDataSource()

    var topics: ObservableArray<TopicWithUserInfo> {
        return model.topics
    }

    func fetch() -> TopicsDataSource.Event {
        return model.fetch(true)
    }

    // MARK: - NSTableViewDataSource

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return model.topics.count
    }

    // MARK: - ViewModel Actions

    func createTopic(topicName: String) -> Observable<CreateTopic.Response> {
        return model.createTopic(topicName)
    }

    func favoriteTopic(topicId: TopicID) -> Observable<FavoriteTopic.Response> {
        return model.favoriteTopic(topicId)
    }

    func unfavoriteTopic(topicId: TopicID) -> Observable<UnfavoriteTopic.Response> {
        return model.unfavoriteTopic(topicId)
    }
}
