//
//  AppReducer.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2016/06/08.
//  Copyright © 2016年 Safx Developers. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRouter
import TypetalkKit

struct AppReducer: Reducer {

    func handleAction(action: Action, state: AppState?) -> AppState {
        return AppState(
            navigationState: NavigationReducer.handleAction(action, state: state?.navigationState),
            topics: topicsReducer(action, state: state?.topics),
            selectedTopic: selectedTopicReducer(action, state: state?.selectedTopic),
            messages: messagesReducer(action, state: state?.messages),
            topicDetail: nil
        )
    }
    
}


func topicsReducer(action: Action, state: [TopicWithUserInfo]?) -> [TopicWithUserInfo]? {
    switch action {
    case let action as SetTopics:
        return action.topics
    default:
        return nil
    }
}

func messagesReducer(action: Action, state: [Post]?) -> [Post]? {
    switch action {
    case let action as SetPosts:
        return action.posts
    default:
        return nil
    }
}


func selectedTopicReducer(action: Action, state: TopicWithUserInfo?) -> TopicWithUserInfo? {
    switch action {
    case let action as ViewTopic:
        return action.topic
    default:
        return nil
    }
}

