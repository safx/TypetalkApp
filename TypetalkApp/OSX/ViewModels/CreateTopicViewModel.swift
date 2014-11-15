//
//  CreateTopicViewModel.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/15.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//


import Cocoa
import TypetalkKit
import ReactiveCocoa
import LlamaKit


class CreateTopicViewModel: NSObject {

    var parentViewModel: TopicListViewModel?
    
    // MARK: - Action

    func createTopic(topicName: String) -> ColdSignal<Client.CreateTopicResponse> {
        return parentViewModel!.createTopic(topicName)
    }
    
}
