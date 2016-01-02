//
//  CreateTopicViewModel.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2014/11/13.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import UIKit
import TypetalkKit
import RxSwift



class CreateTopicViewModel: NSObject, UITableViewDataSource {

    var parentViewModel: TopicListViewModel?
    var topicNameCell: TextFieldCell?
    let topicTitle = Variable("")
    private let disposeBag = DisposeBag()

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell", forIndexPath: indexPath)

        if indexPath.row == 0 {
            if let c = topicNameCell {
                return c
            }
            guard let topicNameCell = cell as? TextFieldCell else {
                return cell
            }
            topicNameCell.textField
                .rx_text
                .throttle(0.05, scheduler: SerialDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
                .distinctUntilChanged()
                .asObservable()
                .observeOn(MainScheduler.instance)
                .bindTo(topicTitle)
                .addDisposableTo(disposeBag)

            return topicNameCell
        }

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

    // MARK: - Action

    func createTopicAction() -> Observable<CreateTopic.Response> {
        return parentViewModel!.createTopicAction(topicTitle.value)
    }

}
