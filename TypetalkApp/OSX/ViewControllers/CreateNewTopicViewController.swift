//
//  CreateTopicViewController.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/14.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Cocoa
import TypetalkKit
import ReactiveCocoa
import LlamaKit

class CreateTopicViewController: NSViewController {
    let viewModel = CreateTopicViewModel()

    @IBAction func textChanged(sender: NSTextField) {
        let topicName = sender.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if !topicName.isEmpty {
            viewModel.createTopic(topicName)
                .start()
        }
        presentingViewController?.dismissViewController(self)
    }
}
