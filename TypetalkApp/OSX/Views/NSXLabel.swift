//
//  NSXLabel.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/05.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import AppKit

class NSXLabel : NSTextField {
    
    override var frame: NSRect {
        didSet {
            switch lineBreakMode {
            case .ByWordWrapping: fallthrough
            case .ByCharWrapping: preferredMaxLayoutWidth = frame.width
            default: ()
            }
        }
    }

    init() {
        super.init(frame: NSMakeRect(0, 0, 0, 0)) // FIXME:RX
        setupView()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.lineBreakMode = .ByClipping
        self.editable = false
        self.bezeled = false
        self.drawsBackground = false
        self.selectable = false
    }
}

class NSXBadgeLabel : NSXLabel {

    override init() {
        super.init(frame: NSMakeRect(0, 0, 0, 0)) // FIXME:RX
        setupView()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override private func setupView() {
        super.setupView()
        alignment = .Center
    }

    override func drawRect(dirtyRect: NSRect) {
        let rect = NSRect(origin: CGPoint(x: 0, y: 0), size: self.bounds.size)
        if let gradient = NSGradient(startingColor: NSColor(calibratedWhite: 0.8, alpha: 1.0),
                                          endingColor: NSColor(calibratedWhite: 0.8, alpha: 1.0)) {
            let path = NSBezierPath(roundedRect: rect, xRadius: 8, yRadius: 8)
            gradient.drawInBezierPath(path, angle: 90)
        }

        super.drawRect(dirtyRect)
    }
}