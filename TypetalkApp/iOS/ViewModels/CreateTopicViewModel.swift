//
//  CreateTopicViewModel.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2014/11/13.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import UIKit
import TypetalkKit
import ReactiveCocoa
import LlamaKit


class CreateTopicViewModel: NSObject, UITableViewDataSource {

    var parentViewModel: TopicListViewModel?
    var topicNameCell: TextFieldCell?
    let topicTitle = ObservableProperty("")

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let c = topicNameCell {
                return c
            }
            topicNameCell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell", forIndexPath: indexPath) as? TextFieldCell
            topicNameCell?.textField
                .rac_textSignal()
                .throttle(0.05)
                .asColdSignal()
                .start { [weak self] res in
                           if let text = res as NSString? {
                               println("\(text)")
                               self?.topicTitle.put(text)
                           }
                       }

            return topicNameCell!
        }

        let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell", forIndexPath: indexPath) as TextFieldCell
        //cell.model = posts.value[indexPath.row]
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

    func createTopicAction() -> ColdSignal<Client.CreateTopicResponse> {
        return parentViewModel!.createTopicAction(topicTitle.value)
    }

}
