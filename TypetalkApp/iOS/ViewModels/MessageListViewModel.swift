//
//  MessageListViewModel.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2014/11/09.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import UIKit
import TypetalkKit
import RxSwift

class MessageListViewModel: NSObject, UITableViewDataSource {
    let model = MessagesDataSource()
    let completionModel = CompletionDataSource()

    let disposeBag = DisposeBag()

    // MARK: - Model ops

    func fetch(topicId: TopicID) {
        model.fetch(topicId)
        completionModel.fetch(topicId)
    }

    func fetchMore(topicId: TopicID) {
        model.fetchMore(topicId)
    }

    func post(message: String) {
        let id = model.topic.value.id
        let s = TypetalkAPI.rx_sendRequest(PostMessage(topicId: id, message: message, replyTo: nil, fileKeys: [], talkIds: []))
        s.subscribe (
            onNext: { res in
                print("\(res)")
                self.fetch(id) // FIXME
            },
            onError: { err in
                print("E \(err)")
            },
            onCompleted:{ () in
            }
        )
        .addDisposableTo(disposeBag)
    }

    func autoCompletionElements(foundPrefix: String, foundWord: String) -> [CompletionDataSource.CompletionModel] {
        return completionModel.autoCompletionElements(foundPrefix, foundWord: foundWord)
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.posts.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
        cell.model = model.posts[model.posts.count - indexPath.row - 1]
        cell.transform = tableView.transform
        return cell
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // TODO
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}
