//
//  TopicsDataSource.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2014/11/09.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import TypetalkKit
import RxSwift


class TopicsDataSource {
    typealias Event = ObservableArray<TopicWithUserInfo>.EventObservableType

    var topics = ObservableArray<TopicWithUserInfo>()

    let disposeBag = DisposeBag()

    func fetch(observe: Bool = false) -> Event {
        let s = TypetalkAPI.rx_sendRequest(GetTopics())
        s.subscribe(
            onNext: { res in
                self.topics.appendContentsOf(res.topics)
            },
            onError: { err in
                print("\(err)")
            },
            onCompleted:{ () in
                if (observe) {
                    self.startObserving()
                }
            }
        )
        .addDisposableTo(disposeBag)
        return topics.rx_event()
    }

    private func startObserving() {
        TypetalkAPI.rx_streamimg
        .subscribeNext { event in
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
        .addDisposableTo(disposeBag)
    }

    private func insertTopic(topic: TopicWithUserInfo) {
        topics.insert(topic, atIndex: 0)
    }

    private func insertTopics(topics: [TopicWithUserInfo]) {
        topics.forEach { self.insertTopic($0) }
    }

    private func find(topicId: TopicID, closure: (TopicWithUserInfo, Int) -> ()) {
        for i in 0..<topics.count {
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
        topics.forEach { self.deleteTopic($0) }
    }

    // MARK: Acting to REST client

    func createTopic(topicName: String) -> Observable<CreateTopic.Response> {
        let teamId: TeamID? = nil
        let inviteMembers = [String]()
        let inviteMessage = ""
        return TypetalkAPI.rx_sendRequest(CreateTopic(name: topicName, teamId: teamId, inviteMembers: inviteMembers, inviteMessage: inviteMessage))
    }

    func deleteTopic(topicId: TopicID) -> Observable<DeleteTopic.Response> {
        return TypetalkAPI.rx_sendRequest(DeleteTopic(topicId: topicId))
    }

    func favoriteTopic(topicId: TopicID) -> Observable<FavoriteTopic.Response> {
        return TypetalkAPI.rx_sendRequest(FavoriteTopic(topicId: topicId))
    }

    func unfavoriteTopic(topicId: TopicID) -> Observable<UnfavoriteTopic.Response> {
        return TypetalkAPI.rx_sendRequest(UnfavoriteTopic(topicId: topicId))
    }
}
