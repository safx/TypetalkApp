//
//  TypetalkActions.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2016/06/08.
//  Copyright © 2016年 Safx Developers. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRouter
import TypetalkKit
import RxSwift


struct RxAction: Action {
    let disposable: Disposable
}

extension Store {
    func rx_dispatch(actionCreatorProvider: (state: State, store: ReSwift.Store<State>) -> Disposable) -> Disposable {
        return actionCreatorProvider(state: state, store: self)
    }
}



struct ViewTopic: Action {
    let topic: TopicWithUserInfo
}



struct SetTopics: Action {
    let topics: [TopicWithUserInfo]
}

struct SetPosts: Action {
    let posts: [Post]
}


func fetchTypetalkGetTopics(state: AppState, store: Store<AppState>) -> Disposable {
    let s = TypetalkAPI.rx_sendRequest(GetTopics())
    let d = s.subscribe(
        onNext: { res in
            store.dispatch(SetTopics(topics: res.topics))
        },
        onError: { err in
            print("\(err)")
        },
        onCompleted:{ () in
        })

    return d
}

func fetchTypetalkGetPosts(state: AppState, store: Store<AppState>) -> Disposable {
    guard let topicId = state.selectedTopic?.topic.id else {
        fatalError() // FIXME
    }

    let s = TypetalkAPI.rx_sendRequest(GetMessages(topicId: topicId))
    let d = s.subscribe(
        onNext: { res in
            store.dispatch(SetPosts(posts: res.posts))
        },
        onError: { err in
            print("\(err)")
        },
        onCompleted:{ () in
    })

    return d
}
