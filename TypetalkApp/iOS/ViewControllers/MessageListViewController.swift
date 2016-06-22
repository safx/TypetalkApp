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
import ReSwift
import SlackTextViewController




class MessageListViewController: SLKTextViewController, StoreSubscriber {

    //private let viewModel = MessageListViewModel()
    //private let dataSource = ArrayDataSource<Post, MessageCell>(identifier: "MessageCell")
    private let dataSource = PostArrayDataSource()

    typealias CompletionModel = CompletionDataSource.CompletionModel

    let completionModel = CompletionDataSource()
    var completionList = [CompletionModel]()
    var oldNumberOfRows = 0

    private let disposeBag = DisposeBag()

    /*var topic: TopicWithUserInfo? {
        didSet {
            self.configureView()
            self.viewModel.fetch(topic!.topic.id)
        }
    }*/

    /*override init!(tableViewStyle style: UITableViewStyle) {
        super.init(tableViewStyle: .Plain)
    }

    required init!(coder decoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }*/

    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Plain
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        inverted = true
        shouldScrollToBottomAfterKeyboardShows = true
        bounces = true
        shakeToClearEnabled = true
        keyboardPanningEnabled = true
        
        tableView!.separatorStyle = .None
        tableView!.estimatedRowHeight = 64
        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.registerClass(MessageCell.self, forCellReuseIdentifier: "MessageCell")

        textView.placeholder = NSLocalizedString("Message", comment: "Message")

        //let icon = IonIcons.imageWithIcon(icon_arrow_down_c, size: 30, color:UIColor.grayColor())
        //leftButton.setImage(icon, forState: .Normal)

        registerPrefixesForAutoCompletion(["@", "#", ":"])
        autoCompletionView.registerClass(AutoCompletionCell.self, forCellReuseIdentifier: "AutoCompletionCell")

        //self.configureView()

        /*weak var weakTableView = tableView
        viewModel.model.posts.rx_events()
            .observeOn(MainScheduler.instance)
            .subscribeNext { next in
                if self.oldNumberOfRows == 0 {
                    self.tableView!.reloadData()
                } else {
                    if let t = weakTableView {
                        let c = self.viewModel.model.posts.count - 1
                        let f = { NSIndexPath(forRow: c - $0, inSection: 0) }
                        let i = next.insertedIndices.map(f)
                        let d = next.deletedIndices.map(f)
                        let u = next.updatedIndices.map(f)
                        t.beginUpdates()
                        t.insertRowsAtIndexPaths(i, withRowAnimation: .None)
                        t.deleteRowsAtIndexPaths(d, withRowAnimation: .Automatic)
                        t.reloadRowsAtIndexPaths(u, withRowAnimation: .Automatic)
                        t.endUpdates()
                    }
                }
                self.oldNumberOfRows = self.viewModel.model.posts.count
            }
            .addDisposableTo(disposeBag)

        tableView!.dataSource = viewModel*/
        tableView!.dataSource = dataSource
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        guard let topic = appStore.state.selectedTopic?.topic else {
            return
        }
        self.title = topic.name

        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) { () -> Void in
            self.completionModel.fetch(topic.id)
            appStore.rx_dispatch(fetchTypetalkGetPosts)
                    .addDisposableTo(self.disposeBag)
        }
        appStore.subscribe(self) { state in
            state.messages
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        appStore.unsubscribe(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ReSwift

    func newState(state: [Post]?) {
        guard let state = state else { return }

        dataSource.model = state
        dispatch_async(dispatch_get_main_queue()) { [weak self] () -> Void in
            self?.tableView?.reloadData()
        }
    }

    //MARK: - Text Editing

    /*override func didPressReturnKey(sender: AnyObject!) {
        post(textView.text)
        super.didPressReturnKey(sender)
    }*/

    override func didPressRightButton(sender: AnyObject!) {
        ///FIXME: viewModel.post(textView.text)
        super.didPressRightButton(sender)
    }

    override func didCommitTextEditing(sender: AnyObject!) {
        super.didCommitTextEditing(sender)
    }

    // MARK: - completion

    override func didChangeAutoCompletionPrefix(prefix: String!, andWord word: String!) {
        completionList = completionModel.autoCompletionElements(foundPrefix!, foundWord: foundWord!)
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
        ///FIXME: self.viewModel.fetchMore(topic!.topic.id)
    }
}



private class PostArrayDataSource: ArrayDataSource<Post, MessageCell> {
    init() {
        super.init(identifier: "MessageCell")
    }
    override func tableView(tableView: TableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! MessageCell
        cell.model = model[model.count - indexPath.row - 1]
        cell.transform = tableView.transform
        return cell
    }
}


