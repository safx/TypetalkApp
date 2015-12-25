//
//  CompletionDataSource.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2014/11/09.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import TypetalkKit
import RxSwift
import Emoji

class CompletionDataSource {
    let accounts = Variable([AccountWithOnlineStatus]())
    let talks = Variable([Talk]())
    let disposeBag = DisposeBag()

    // MARK: - Model ops

    func fetch(topicId: TopicID) {
        fetchTopicMembers(topicId)
        fetchTalks(topicId)
    }
    
    private func fetchTopicMembers(topicId: TopicID) {
        let s = TypetalkAPI.request(GetTopicMembers(topicId: topicId))
        s.subscribe(
            onNext: { res in
                self.accounts.value = res.accounts
            },
            onError: { err in
                print("E \(err)")
            },
            onCompleted:{ () in
            }
        )
        .addDisposableTo(disposeBag)
    }
    
    private func fetchTalks(topicId: TopicID) {
        let s = TypetalkAPI.request(GetTalks(topicId: topicId))
        s.subscribe(
            onNext: { res in
                self.talks.value = res.talks
            },
            onError: { err in
                print("E \(err)")
            },
            onCompleted:{ () in
            }
        )
        .addDisposableTo(disposeBag)
    }

    private func _filterfunc<T>(foundWord: String, key:(T -> String))(e: T) -> Bool {
        if foundWord.isEmpty {
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
            return String.emojiDictionary.filter(_filterfunc(foundWord, key: { (k,v) in k }))
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
