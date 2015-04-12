//
//  CompletionDataSource.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2014/11/09.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import TypetalkKit
import ReactiveCocoa
import Emoji

class CompletionDataSource {
    let accounts = ObservableProperty([AccountWithOnlineStatus]())
    let talks = ObservableProperty([Talk]())

    // MARK: - Model ops

    func fetch(topicId: TopicID) {
        fetchTopicMembers(topicId)
        fetchTalks(topicId)
    }
    
    private func fetchTopicMembers(topicId: TopicID) {
        let s = Client.sharedClient.getTopicMembers(topicId)
        s.start(
            next: { res in
                self.accounts.put(res.accounts)
            },
            error: { err in
                println("E \(err)")
            },
            completed:{ () in
            }
        )
    }
    
    private func fetchTalks(topicId: TopicID) {
        let s = Client.sharedClient.getTalks(topicId)
        s.start(
            next: { res in
                self.talks.put(res.talks)
            },
            error: { err in
                println("E \(err)")
            },
            completed:{ () in
            }
        )
    }

    private func _filterfunc<T>(foundWord: String, key:(T -> String))(e: T) -> Bool {
        if countElements(foundWord) == 0 {
            return true
        }
        
        let n = key(e)
        if let r = n.rangeOfString(foundWord) {
            return r.startIndex == n.startIndex
        }
        return false
    }

    func autoCompletionElements(foundPrefix: String, foundWord: String) -> [CompletionModel] {
        switch foundPrefix {
        case "@":
            return accounts.value
                .filter(_filterfunc(foundWord, key: { $0.account.name }))
                .map { CompletionModel(text: $0.account.name, description: $0.account.fullName, imageURL: $0.account.imageUrl, online: $0.online) }
        case "#":
            return talks.value
                .filter(_filterfunc(foundWord, key: { $0.name }))
                .map { CompletionModel(text: $0.name, description: $0.suggestion) }
        case ":":
            return filter(String.emojiDictionary, _filterfunc(foundWord, key: { (k,v) in k }))
                .map { (k,v) in CompletionModel(text: k, description: v, completionString: "\(k):") }
        default:
            return []
        }
    }

    struct CompletionModel {
        let text: String
        let completionString: String
        let description: String
        let imageURL: NSURL?
        let online: Bool
        
        init(text: String, description: String, completionString: String? = nil, imageURL: NSURL? = nil, online: Bool = true) {
            self.text = text
            self.completionString = completionString ?? text
            self.description = description
            self.imageURL = imageURL
            self.online = online
        }
    }
}
