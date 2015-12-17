//
//  CreateTopicViewModel.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/15.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//


import Cocoa
import TypetalkKit
import RxSwift


class CreateTopicViewModel: NSObject {

    var parentViewModel: TopicListViewModel?
    
    // MARK: - Action

    func createTopic(topicName: String) -> Observable<CreateTopic.Response> {
        return parentViewModel!.createTopic(topicName)
    }
    
}
