//
//  TopicViewController.swift
//  TypetalkSample-OSX
//
//  Created by Safx Developer on 2015/01/29.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Cocoa
import TypetalkKit


class TopicViewController: NSViewController, NSTableViewDelegate, NSMenuDelegate {
    @IBOutlet weak var tableView: NSTableView!
    private let viewModel = TopicListViewModel()
    private var oldNumberOfRows = 0

    private var selectedTopic: TopicWithUserInfo? {
        let row = tableView.selectedRow
        if 0 <= row && row < countElements(viewModel.topics) {
            return viewModel.topics[row]
        }
        return nil
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.enclosingScrollView?.borderType = .NoBorder
        tableView.setDataSource(viewModel)
        tableView.setDelegate(self)

        weak var weakTableView = tableView
        viewModel.fetch()
            .observe { next in
                let rows = self.viewModel.topics.count
                switch next {
                case .Inserted(let indeces):
                    if self.oldNumberOfRows == 0 {
                        NSTableView.reloadData(weakTableView)
                    } else {
                        NSTableView.update(weakTableView) { t in
                            t.insertRowsAtIndexes(NSTableView.asIndexSet(indeces), withAnimation: .EffectFade)
                        }
                    }
                case .Deleted(let (indeces, elements)):
                    NSTableView.update(weakTableView) { t in
                        t.removeRowsAtIndexes(NSTableView.asIndexSet(indeces), withAnimation: .EffectFade)
                    }
                case .Updated(let indeces):
                    NSTableView.update(weakTableView) { t in
                        t.updateRowsAtIndexes(NSTableView.asIndexSet(indeces), withAnimation: .EffectFade)
                    }
                }
                self.oldNumberOfRows = rows
            }

        let menu = NSMenu(title: "Topic Item Menu")
        menu.delegate = self
        tableView.menu = menu
    }

    // MARK: - Action

    @IBAction func columnChangeSelected(sender: NSTableView) {
        selectedTopic.map { topic -> () in
            let controller = self.parentViewController?.childViewControllers[1].childViewControllers[0] as MessageViewController
            controller.topic = topic
        }
    }

    func editTopic(sender: NSMenuItem) {
        performSegueWithIdentifier("editTopic", sender: nil)
    }

    func unfavoriteTopic(sender: NSMenuItem) {
        selectedTopic.map {
            self.viewModel.unfavoriteTopic($0.topic.id)
                .start()
        }
    }

    func favoriteTopic(sender: NSMenuItem) {
        selectedTopic.map {
            self.viewModel.favoriteTopic($0.topic.id)
                .start()
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "newTopic" {
            let controller = segue.destinationController as CreateTopicViewController
            controller.viewModel.parentViewModel = viewModel
        } else if segue.identifier == "editTopic" {
            let controller = segue.destinationController as EditTopicViewController
            controller.topic = selectedTopic!.topic
        }
    }

    // MARK: - NSMenuDelegate

    func menuNeedsUpdate(menu: NSMenu) {
        if let topic = selectedTopic {
            menu.removeAllItems()
            let item1 = NSMenuItem(title: topic.favorite ? "Unfavorite topic" : "Favorite topic",
                action: topic.favorite ? "unfavoriteTopic:" : "favoriteTopic:", keyEquivalent: "f")
            let item2 = NSMenuItem(title: "Edit topic", action: "editTopic:", keyEquivalent: "e")
            item1.enabled = true
            item2.enabled = true
            menu.addItem(item1)
            menu.addItem(item2)
        }
    }

    // MARK: - NSTableViewDelegate

    func tableView(tableView: NSTableView, viewForTableColumn: NSTableColumn, row: Int) -> NSView? {
        if 0 <= row && row < viewModel.topics.count {
            return TopicCell(model: viewModel.topics[row])
        }
        return nil
    }

    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
}
