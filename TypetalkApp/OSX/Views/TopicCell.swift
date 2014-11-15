//
//  TopicCell.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/22.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Cocoa
import TypetalkKit
import Alamofire
import yavfl

class TopicCell: NSTableCellView {
    private let image = NSImageView()
    private let name  = NSXLabel()
    private let badge = NSXBadgeLabel()
    private var badgeWidthConstraint: NSLayoutConstraint?

    private(set) var model: TopicWithUserInfo? {
        didSet { modelDidSet() }
    }

    private var unreadCount: Int {
        if let unread = model!.unread {
            return unread.count
        }
        return 0
    }

    init(model: TopicWithUserInfo) {
        super.init()
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
        name.stringValue = model!.topic.name
        image.image = NSImage(named: model!.favorite ? "NSStatusAvailable" : "NSStatusNone")

        let c = unreadCount
        if c > 0 {
            badge.stringValue = "\(c)"
            badge.hidden = false
            badgeWidthConstraint?.constant = 16
        } else {
            badge.stringValue = ""
            badge.hidden = true
            badgeWidthConstraint?.constant = 0
        }
    }

    private func setupView() {
        name.font = NSFont(name: "Helvetica Neue", size: 13)
        name.lineBreakMode = .ByTruncatingTail
        name.setContentHuggingPriority(1, forOrientation: .Vertical)
        badge.font = NSFont(name: "Helvetica Neue", size: 13)

        for i in [name, image, badge] {
            self.addSubview(i)
        }

        var cs: [AnyObject] = []
        visualFormat(image, name, badge) { img, name, badge in
            .H ~ |-4-[img]-4-[name]-4-[badge]-4-| % .AlignAllCenterY
            .H ~ [img,==16]
            .V ~ |-4-[name]-4-|
            .V ~ |-4-[img]-4-|
            .V ~ |-4-[badge]-4-|
            cs = .H ~ [badge,>=16]
        }
        if countElements(cs) > 0 {
            self.badgeWidthConstraint = cs[0] as NSLayoutConstraint
        }
    }
}