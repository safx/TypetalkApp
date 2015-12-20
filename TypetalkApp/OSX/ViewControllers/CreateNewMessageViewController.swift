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
import RxSwift


class CreateNewMessageViewController: NSViewController {

    @IBOutlet var messageBox: NSTextField!
    @IBOutlet weak var postButton: NSButton!
    @IBOutlet weak var messageViewController: MessageViewController!

    let viewModel = CreateNewMessageViewModel()
    var topic: TopicWithUserInfo?

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        weak var weakSelf = self

        messageBox
            .rx_text
            .throttle(0.05, MainScheduler.sharedInstance)
            .distinctUntilChanged()
            .subscribeNext { res in
                if let text = res as NSString? {
                    Swift.print("\(text)")
                    weakSelf?.postButton.enabled = text.length > 0
                }
            }
            .addDisposableTo(disposeBag)

    }

    @IBAction func postMessage(sender: AnyObject) {
        guard viewModel.parentViewModel != nil else { return }

        let text = messageBox.stringValue
        guard !text.isEmpty else { return }

        viewModel.postMessage(text)
            .subscribeNext { [weak self] v in
                dispatch_async(dispatch_get_main_queue()) {
                    self?.messageBox.stringValue = ""
                    ()
                }
                ()
            }
            .addDisposableTo(disposeBag)
    }
}
