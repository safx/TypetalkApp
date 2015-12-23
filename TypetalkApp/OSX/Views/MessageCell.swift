//
//  MessageCell.swift
//  TypetalkSample-OSX
//
//  Created by Safx Developer on 2015/01/31.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import AppKit
import Cocoa
import TypetalkKit
import Alamofire
import yavfl
import Emoji
import RxSwift

class MessageCell: NSTableCellView {
    private let message = MarkdownView()
    private let lastUpdate = NSXLabel()
    private let accountImage = NSImageView()
    private let accountName = NSXLabel()
    private var attachments = [AttachmentView]()
    private var constraint: NSLayoutConstraint?

    private let disposeBag = DisposeBag()

    private(set) var model: Post? {
        didSet { modelDidSet() }
    }

    init(model: Post) {
        super.init(frame: NSMakeRect(0, 0, 0, 0)) // FIXME:RX
        setupView()
        self.model = model
        modelDidSet()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func modelDidSet() {
        let node = MarkdownNode.parse(model!.message)
        message.node = node.markdownLite

        accountName.stringValue = model!.account.name

        let updated = model!.updatedAt.humanReadableTimeInterval
        let numLikes = model!.likes.count

        if numLikes > 0 {
            // ♡
            lastUpdate.stringValue = "\(updated) ♥\(numLikes)"
        } else {
            lastUpdate.stringValue = "\(updated)"
        }

        let url = model!.account.imageUrl

        Alamofire.request(Alamofire.Method.GET, url)
            .rx_response()
            .subscribe(onNext: { data -> Void in
                dispatch_async(dispatch_get_main_queue(), { () in
                    self.accountImage.image = NSImage(data: data)
                })
            }, onError: { err -> Void in
                Swift.print("\(err)")
            }, onCompleted: { () -> Void in
                //Swift.print("Completed \(url)")
            })
            .addDisposableTo(disposeBag)

        var prev: NSView = message
        for i in model!.attachments {
            let att = AttachmentView(attachment: i)
            self.addSubview(att)
            self.attachments.append(att)
            visualFormat(accountImage, prev, att) { img, prev, att in
                .H ~ |-20-[att]-20-|;
                .V ~ [img]-(>=4)-[att];
                .V ~ [prev]-8-[att];
                .V ~ [att,==200~250];
            }
            prev = att
        }

        constraint = NSLayoutConstraint(item: prev, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -8)
        self.addConstraint(constraint!)
    }

    override func prepareForReuse() {
        for i in attachments {
            i.removeFromSuperview()
        }
        attachments.removeAll(keepCapacity: true)
        if let c = constraint {
            self.removeConstraint(c)
        }
    }

    private func setupView() {
        let fm = NSFontManager.sharedFontManager()

        message.setContentHuggingPriority(1, forOrientation: .Vertical)
        accountName.font = fm.fontWithFamily("Helvetica Neue", traits: .BoldFontMask, weight: 0, size: 12)
        accountName.textColor = NSColor.blackColor()
        lastUpdate.font = NSFont(name: "Helvetica Neue", size: 12)
        lastUpdate.textColor = NSColor.grayColor()

        for i in [message, accountName, lastUpdate, accountImage] {
            self.addSubview(i)
        }

        visualFormat(message) { mes in
            .H ~ |-64-[mes]-8-|;
            .V ~ |-28-[mes];
        }

        visualFormat(lastUpdate, message, accountImage, accountName) { up, mes, img, name in
            .H ~ |-8-[img,==40]-16-[name];
            .H ~ [name]-8-[up] % .AlignAllBaseline;
            .V ~ |-4-[img,==40];
            .V ~ |-4-[name,==20];
        }

        updateConstraints()
    }

    // TODO: remove magic number
    class func estimateCellHeight(model: Post, bounds: NSRect) -> CGFloat {
        //let font = NSFont(name: "Helvetica Neue", size: 13)!
        //let attr: [NSObject:AnyObject] = [NSFontAttributeName: font]

        // TODO: cache node
        let node = MarkdownNode.parse(model.message)
        let messageHeight = node.markdownLite.getHeight(bounds.size.width - 74)

        let attachment_heights = model.attachments.map(AttachmentView.viewHeight)
        let total_attachment_height = CGFloat(attachment_heights.reduce(8, combine: +))

        return max(messageHeight + total_attachment_height + 36, 56)
    }
}
