//
//  TopicInfoDataSource.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/22.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import TypetalkKit
import RxSwift
import ObservableArray

class TopicInfoDataSource {
    typealias Event = ObservableArray<Post>.EventType

    let topic = Variable(Topic())
    let teams = Variable([TeamWithMembers]())
    let accounts = Variable([Account]())
    let invites = Variable([TopicInvite]())

    private let disposeBag = DisposeBag()

    // MARK: - Model ops

    func fetch(topicId: TopicID) {
        let s = TypetalkAPI.rx_sendRequest(GetTopicDetails(topicId: topicId))
        s.subscribeNext { res in
            self.topic.value = res.topic
            self.teams.value = res.teams
            self.accounts.value = res.accounts
            self.invites.value = res.invites
        }
        .addDisposableTo(disposeBag)
    }

    func updateTopic(topicId: TopicID, name: String, teamId: TeamID?) -> Observable<UpdateTopic.Response> {
        return TypetalkAPI.rx_sendRequest(UpdateTopic(topicId: topicId, name: name, teamId: teamId))
    }

    func deleteTopic(topicId: TopicID) -> Observable<DeleteTopic.Response> {
        return TypetalkAPI.rx_sendRequest(DeleteTopic(topicId: topicId))
    }
}
