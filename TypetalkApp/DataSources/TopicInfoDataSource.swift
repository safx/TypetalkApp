//
//  TopicInfoDataSource.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/22.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import TypetalkKit
import ReactiveCocoa

class TopicInfoDataSource {
    typealias Signal = ObservableArray<Post>.Signal

    let topic = ObservableProperty(Topic())
    let teams = ObservableProperty([TeamWithMembers]())
    let accounts = ObservableProperty([Account]())
    let invites = ObservableProperty([TopicInvite]())

    // MARK: - Model ops

    func fetch(topicId: TopicID) {
        let s = Client.sharedClient.getTopicDetails(topicId)
        s.start(
            next: { res in
                self.topic.put(res.topic)
                self.teams.put(res.teams)
                self.accounts.put(res.accounts)
                self.invites.put(res.invites)
            })
    }

    func updateTopic(topicId: TopicID, name: String, teamId: TeamID?) -> ColdSignal<Client.UpdateTopicResponse> {
        return Client.sharedClient.updateTopic(topicId, name: name, teamId: teamId)
    }

    func deleteTopic(topicId: TopicID) -> ColdSignal<Client.DeleteTopicResponse> {
        return Client.sharedClient.deleteTopic(topicId)
    }
}
