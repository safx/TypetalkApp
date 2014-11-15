//
//  EditTopicViewController.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/22.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Cocoa
import TypetalkKit
import ReactiveCocoa
import LlamaKit


class EditTopicViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    let viewModel = EditTopicViewModel()
    @IBOutlet weak var topicNameLabel: NSTextField!
    @IBOutlet weak var teamListBox: NSComboBox!
    @IBOutlet weak var idLabel: NSTextField!
    @IBOutlet weak var createdLabel: NSTextField!
    @IBOutlet weak var updatedLabel: NSTextField!
    @IBOutlet weak var lastPostedLabel: NSTextField!
    @IBOutlet weak var acceptButton: NSButton!
    @IBOutlet weak var membersTableView: NSTableView!
    @IBOutlet weak var invitesTableView: NSTableView!

    var topic: Topic? = nil {
        didSet {
            self.viewModel.fetch(topic!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        membersTableView.setDelegate(self)
        membersTableView.setDataSource(self)
        invitesTableView.setDelegate(self)
        invitesTableView.setDataSource(self)

        teamListBox.editable = false
        acceptButton.enabled = false

        precondition(topic != nil)
        self.topicNameLabel.stringValue = topic!.name
        self.idLabel.stringValue = "\(topic!.id)"
        self.createdLabel.stringValue = topic!.createdAt.humanReadableTimeInterval
        self.updatedLabel.stringValue = topic!.updatedAt.humanReadableTimeInterval
        if let posted = topic!.lastPostedAt {
            self.lastPostedLabel.stringValue = posted.humanReadableTimeInterval
        }

        viewModel.teamListIndex.values.combineLatestWith(viewModel.teamList.values)
            .filter { $0.1.count > 0 }
            .deliverOn(MainScheduler())
            .start(next: { (index, teams) -> () in
                self.teamListBox.removeAllItems()
                self.teamListBox.addItemsWithObjectValues(teams.map { $0.description } )
                self.teamListBox.selectItemAtIndex(index)
                self.acceptButton.enabled = true
            })

        teamListBox
            .rac_selectionSignal()
            .combineLatestWith(viewModel.teamList.values)
            .map { $0.1 }
            .filter { $0.count > 0 }
            .start { [weak self] teams in
                if let s = self {
                    let idx = s.teamListBox.indexOfSelectedItem
                    if 0 <= idx && idx < teams.count {
                        s.viewModel.teamId.put(teams[idx].id)
                    }
                }
            }

        topicNameLabel
            .rac_textSignal()
            .throttle(0.05)
            .asColdSignal()
            .start { [weak self] res in
                if let text = res as NSString? {
                    self?.viewModel.topicName.put(text)
                }
            }

        viewModel.accounts.values
            .deliverOn(MainScheduler())
            .start(next: { [weak self] _ in
                self?.membersTableView.reloadData()
                ()
            })

        viewModel.invites.values
            .deliverOn(MainScheduler())
            .start(next: { [weak self] _ in
                self?.invitesTableView.reloadData()
                ()
            })
    }

    @IBAction func deleteTopic(sender: AnyObject) {
        let alert = NSAlert()
        alert.addButtonWithTitle("Delete")
        alert.addButtonWithTitle("Cancel")

        let bs = alert.buttons as [NSButton]
        bs[0].keyEquivalent = "\033"
        bs[1].keyEquivalent = "\r"

        alert.messageText = "Remove “\(topic!.name)”"
        alert.informativeText = "WARNING: All messages in this topic will be removed permanently."
        alert.alertStyle = .WarningAlertStyle

        if let key = NSApp.keyWindow? {
            alert.beginSheetModalForWindow(key) { [weak self] res in
                if res == NSAlertFirstButtonReturn {
                    if let s = self {
                        s.viewModel.deleteTopic()
                        s.presentingViewController?.dismissViewController(s)
                    }
                }
            }
        }
    }

    @IBAction func exit(sender: NSButton) {
        presentingViewController?.dismissViewController(self)
    }
    @IBAction func accept(sender: AnyObject) {
        viewModel.updateTopic()
        presentingViewController?.dismissViewController(self)
    }

    // MARK: - NSTableViewDataSource

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if tableView == membersTableView {
            return viewModel.accounts.value.count
        } else if tableView == invitesTableView {
            return viewModel.invites.value.count
        }
        return 0
    }

    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if let i = tableColumn?.identifier {
            if tableView == membersTableView && 0 <= row && row < viewModel.accounts.value.count {
                let account = viewModel.accounts.value[row]
                if i == "image" { return NSImage(contentsOfURL: account.imageUrl) }
                if i == "name"  { return account.name }
                if i == "date"  { return account.createdAt.humanReadableTimeInterval }
            }
            else if tableView == invitesTableView && 0 <= row && row < viewModel.invites.value.count {
                let invite = viewModel.invites.value[row]
                if i == "image" {
                    if let a = invite.account {
                        return NSImage(contentsOfURL: a.imageUrl)
                    }
                }
                if i == "name"    { return invite.account?.name ?? "" }
                if i == "status"  { return invite.status }
                if i == "date"    { return invite.createdAt.humanReadableTimeInterval }
            }
        }
        return nil
    }

    // MARK: - NSTableViewDelegate

    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 20
    }
}
