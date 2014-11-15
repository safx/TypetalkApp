//
//  TopicsDataSource.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2014/11/09.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import TypetalkKit
import ReactiveCocoa
import LlamaKit

class TopicsDataSource {
    typealias Signal = ObservableArray<TopicWithUserInfo>.Signal

    let topics = ObservableArray<TopicWithUserInfo>()

    func fetch(observe: Bool = false) -> Signal {
        let s = Client.sharedClient.getTopics()
        s.start(
            next: { res in
                self.topics.extend(res.topics)
            },
            error: { err in
                println("\(err)")
            },
            completed:{ () in
                if (observe) {
                    self.startObserving()
                }
            }
        )
        return topics.signal
    }

    private func startObserving() {
        let s = Client.sharedClient.streamimgSignal
        s.observe { event in
            switch event {
            case .CreateTopic(let res):     self.insertTopic(res)
            case .DeleteTopic(let res):     self.deleteTopic(res)
            case .UpdateTopic(let res):     self.updateTopic(res)
            case .JoinTopics(let res):      self.insertTopics(res.topics)
            case .LeaveTopics(let res):     self.deleteTopics(res.topics)
            case .FavoriteTopic(let res):   self.updateTopic(res)
            case .UnfavoriteTopic(let res): self.updateTopic(res)
            case .PostMessage(let res):     self.updateTopic(res.topic!, post: res.post!, advance: +1)
            case .DeleteMessage(let res):   self.updateTopic(res.topic!, post: res.post!, advance: -1)
            case .SaveBookmark(let res):    self.updateTopic(res.unread)
            default: ()
            }
        }
    }

    private func insertTopic(topic: TopicWithUserInfo) {
        topics.insert(topic, atIndex: 0)
    }

    private func insertTopics(topics: [TopicWithUserInfo]) {
        topics.map { self.insertTopic($0) }
    }

    private func find(topicId: TopicID, closure: (TopicWithUserInfo, Int) -> ()) {
        for var i = 0; i < countElements(topics); ++i {
            if topics[i].topic.id == topicId {
                closure(topics[i], i)
                return
            }
        }
    }
    
    private func updateTopic(topic: Topic) {
        find(topic.id) { oldValue, i in
            self.topics[i] = TopicWithUserInfo(topic: topic, favorite: oldValue.favorite, unread: oldValue.unread)
        }
    }

    private func updateTopic(topicWithUserInfo: TopicWithUserInfo) {
        find(topicWithUserInfo.topic.id) { oldValue, i in
            self.topics[i] = topicWithUserInfo
        }
    }

    private func updateTopic(unread: Unread) {
        find(unread.topicId) { oldValue, i in
            self.topics[i] = TopicWithUserInfo(topic: oldValue.topic, favorite: oldValue.favorite, unread: unread)
        }
    }

    private func updateTopic(topic: Topic, post: Post, advance: Int) {
        find(topic.id) { oldValue, i in
            let c = (oldValue.unread?.count ?? 0) + advance
            let unread = Unread(topicId: topic.id, postId: post.id, count: max(c, 0))
            self.topics[i] = TopicWithUserInfo(topic: topic, favorite: oldValue.favorite, unread: unread)
        }
    }

    private func deleteTopic(topic: Topic) {
        find(topic.id) { oldValue, i in
            self.topics.removeAtIndex(i)
            ()
        }
    }

    private func deleteTopics(topics: [Topic]) {
        topics.map { self.deleteTopic($0) }
    }

    // MARK: Acting to REST client

    func createTopic(topicName: String) -> ColdSignal<Client.CreateTopicResponse> {
        let teamId: TeamID? = nil
        let inviteMembers = [String]()
        let inviteMessage = ""
        return Client.sharedClient.createTopic(topicName, teamId: teamId, inviteMembers: inviteMembers, inviteMessage: inviteMessage)
    }

    func deleteTopic(topicId: TopicID) -> ColdSignal<Client.DeleteTopicResponse> {
        return Client.sharedClient.deleteTopic(topicId)
    }

    func favoriteTopic(topicId: TopicID) -> ColdSignal<Client.FavoriteTopicResponse> {
        return Client.sharedClient.favoriteTopic(topicId)
    }

    func unfavoriteTopic(topicId: TopicID) -> ColdSignal<Client.UnfavoriteTopicResponse> {
        return Client.sharedClient.unfavoriteTopic(topicId)
    }
}
