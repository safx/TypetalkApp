//
//  CreateNewMessageViewController.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/03/07.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation

import Cocoa
import TypetalkKit
import ReactiveCocoa
import LlamaKit

class CreateNewMessageViewController: NSViewController {

    @IBOutlet var messageBox: NSTextView!
    @IBOutlet weak var postButton: NSButton!

    let viewModel = CreateNewMessageViewModel()
    var parentViewModel: MessageListViewModel?
    var topic: TopicWithUserInfo?

    override func viewDidLoad() {
        weak var weakSelf = self
        messageBox
            .rac_textSignal()
            .throttle(0.05)
            .asColdSignal()
            .start { res in
                if let text = res as NSString? {
                    println("\(text)")
                    weakSelf?.postButton.enabled = text.length > 0
                }
        }

    }

    @IBAction func postMessage(sender: AnyObject) {
        if let text = messageBox.string {
            if text == "" { return }

            viewModel.postMessage(text)
                .start { [weak self] v in
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.messageBox.string = ""
                        ()
                    }
                    ()
                }
        }
    }
}
