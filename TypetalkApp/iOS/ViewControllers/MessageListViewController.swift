//
//  MessageListViewController.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2014/11/08.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import UIKit
import TypetalkKit
import RxSwift
import SlackTextViewController

class MessageListViewController: SLKTextViewController {

    private let viewModel = MessageListViewModel()

    typealias CompletionModel = CompletionDataSource.CompletionModel
    var completionList = [CompletionModel]()
    var oldNumberOfRows = 0

    private let disposeBag = DisposeBag()

    var topic: TopicWithUserInfo? {
        didSet {
            self.configureView()
            self.viewModel.fetch(topic!.topic.id)
        }
    }

    /*override init!(tableViewStyle style: UITableViewStyle) {
        super.init(tableViewStyle: .Plain)
    }

    required init!(coder decoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }*/

    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Plain
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let t = self.topic {
            self.title = t.topic.name
        }
    }

    private class func asIndexPath(indeces: [Int]) -> [NSIndexPath] {
        return indeces.map { NSIndexPath(forRow: $0, inSection: 0) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        inverted = true
        shouldScrollToBottomAfterKeyboardShows = true
        bounces = true
        shakeToClearEnabled = true
        keyboardPanningEnabled = true
        
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerClass(MessageCell.self, forCellReuseIdentifier: "MessageCell")

        textView.placeholder = NSLocalizedString("Message", comment: "Message")

        //let icon = IonIcons.imageWithIcon(icon_arrow_down_c, size: 30, color:UIColor.grayColor())
        //leftButton.setImage(icon, forState: .Normal)

        registerPrefixesForAutoCompletion(["@", "#", ":"])
        autoCompletionView.registerClass(AutoCompletionCell.self, forCellReuseIdentifier: "AutoCompletionCell")

        self.configureView()

        weak var weakTableView = tableView
        viewModel.model.posts.event
            .subscribeNext { next in
                switch next {
                case .Inserted(let indeces):
                    if self.oldNumberOfRows == 0 {
                        dispatch_async(dispatch_get_main_queue()) { () in
                            self.tableView.reloadData()
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            if let t = weakTableView {
                                let added = MessageListViewController.asIndexPath(indeces)
                                t.beginUpdates()
                                t.insertRowsAtIndexPaths(added, withRowAnimation: .None)
                                t.endUpdates()

                                /*if indeces.count > 0 {
                                    let c = self.viewModel.model.posts.count
                                    t.scrollRowToVisible(c - 1)
                                }*/
                            }
                        }
                    }
                case .Deleted: //(let (indeces, elements)):
                    dispatch_async(dispatch_get_main_queue()) { () in
                        self.tableView.reloadData()
                    }
                case .Updated: //(let indeces):
                    dispatch_async(dispatch_get_main_queue()) { () in
                        self.tableView.reloadData()
                    }
                }
                self.oldNumberOfRows = self.viewModel.model.posts.count
            }
            .addDisposableTo(disposeBag)

        tableView.dataSource = viewModel
        //viewModel.fetch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Text Editing

    /*override func didPressReturnKey(sender: AnyObject!) {
        post(textView.text)
        super.didPressReturnKey(sender)
    }*/

    override func didPressRightButton(sender: AnyObject!) {
        viewModel.post(textView.text)
        super.didPressRightButton(sender)
    }

    override func didCommitTextEditing(sender: AnyObject!) {
        super.didCommitTextEditing(sender)
    }

    // MARK: - completion

    override func didChangeAutoCompletionPrefix(prefix: String!, andWord word: String!) {
        completionList = viewModel.autoCompletionElements(foundPrefix, foundWord: foundWord)
        showAutoCompletionView(!completionList.isEmpty)
    }

    override func heightForAutoCompletionView() -> CGFloat {
        let len = completionList.count
        return CGFloat(len * 36)
    }

    // MARK: UITableViewDataSource Methods (for Completion)

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completionList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AutoCompletionCell", forIndexPath: indexPath) as! AutoCompletionCell
        cell.setModel(completionList[indexPath.row])
        return cell
    }

    // MARK: UITableViewDelegate Methods

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == autoCompletionView {
            let c = completionList[indexPath.row]
            acceptAutoCompletionWithString("\(c.completionString) ")
        }
    }
    
    // MARK: - load
    
    func handleMore(sender: AnyObject!) {
        self.viewModel.fetchMore(topic!.topic.id)
    }
}
