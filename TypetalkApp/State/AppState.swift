//
//  AppState.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2016/06/07.
//  Copyright © 2016年 Safx Developers. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRouter
import TypetalkKit

struct AppState: StateType, HasNavigationState {
    var navigationState: NavigationState

    var topics: [TopicWithUserInfo]?

    var selectedTopic: TopicWithUserInfo?
    var messages: [Post]?
    var topicDetail: TopicWithAccounts?
}
