//
//  MessageViewController.swift
//  TypetalkSample-OSX
//
//  Created by Safx Developer on 2015/01/29.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Cocoa
import TypetalkKit
import RxSwift


class MessageViewController: NSViewController, NSTableViewDelegate {

    @IBOutlet weak var tableView: NSTableView!
    internal let viewModel = MessageListViewModel()
    private var oldNumberOfRows = 0

    private let disposeBag = DisposeBag()

    var topic: TopicWithUserInfo? = nil {
        didSet {
            self.title = topic!.topic.name
            self.viewModel.fetch(topic!.topic.id)
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.enclosingScrollView?.borderType = .NoBorder
        tableView.selectionHighlightStyle = .None
        tableView.setDataSource(viewModel)
        tableView.setDelegate(self)

        //let controller = self.parentViewController?.childViewControllers[1]
            //.childViewControllers[0] as CreateNewMessageViewController
        //controller.topic = topic

        weak var weakSelf = self
        weak var weakTableView = tableView
        viewModel.postsEvent
            .subscribeNext { event in
                if let s = weakSelf {
                    let rows = self.viewModel.posts.count
                    if s.oldNumberOfRows == 0 {
                        NSTableView.reloadData(weakTableView)
                    } else {
                        NSTableView.update(weakTableView) { t in
                            t.insertRowsAtIndexes(NSTableView.asIndexSet(event.insertedIndeces), withAnimation: .EffectNone)
                            t.removeRowsAtIndexes(NSTableView.asIndexSet(event.deletedIndeces), withAnimation: .EffectFade)
                            t.updateRowsAtIndexes(NSTableView.asIndexSet(event.updatedIndeces), withAnimation: .EffectFade)

                            if let idx = event.insertedIndeces.first {
                                let moveIndex = idx == 0 ? event.insertedIndeces.count : idx
                                weakTableView?.scrollRowToVisible(moveIndex)
                            }
                        }
                    }
                    s.oldNumberOfRows = rows
                }
            }
            .addDisposableTo(disposeBag)

        viewModel.bookmarkIndex
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { idx in
                assert(NSThread.mainThread() == NSThread.currentThread(), "UI Thread expected.")
                weakTableView?.scrollRowToVisible(idx)
            }
            .addDisposableTo(disposeBag)

        tableView.postsFrameChangedNotifications = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "tableViewFrameDidChange:", name: NSViewFrameDidChangeNotification, object: tableView)

        let scrollView = tableView.superview!.superview! as! NSScrollView
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollViewDidLiveScroll:", name: NSScrollViewDidLiveScrollNotification, object: scrollView)

    }

    // MARK: - TableViewDelegate

    func tableView(tableView: NSTableView, viewForTableColumn: NSTableColumn?, row: Int) -> NSView? {
        if 0 <= row && row < viewModel.posts.count {
            return MessageCell(model: viewModel.posts[row])
        }
        return nil
    }

    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let post = viewModel.posts[row]
        return MessageCell.estimateCellHeight(post, bounds: tableView.bounds)
    }

    // MARK: - Notifications

    func scrollViewDidLiveScroll(notification: NSNotification) {
        let clipView = tableView.superview! as! NSClipView
        if clipView.bounds.origin.y < 0 {
            viewModel.fetchMore(topic!.topic.id)
        }
    }

    func tableViewFrameDidChange(notification: NSNotification) {
        let range = tableView.rowsInRect(tableView.bounds)
        let indexSet = NSIndexSet(indexesInRange: range)
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration = 0
        tableView.noteHeightOfRowsWithIndexesChanged(indexSet)
        NSAnimationContext.endGrouping()
    }

    // MARK: - Segue

    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier {
            if id == "create-message" {
                let controller = segue.destinationController as! CreateNewMessageViewController
                controller.viewModel.parentViewModel = viewModel
                controller.topic = topic
            }
        }
    }
}
