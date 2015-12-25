//
//  MarkdownView.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/04/21.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import AppKit

class MarkdownView : NSView {

    var node: MarkdownBlock?

    override func drawRect(rect: CGRect) {
        //let context = NSStringDrawingContext()
        //context.minimumScaleFactor = 0.5
        if let n = node {
            let c = WithCurrentGraphicsContext(rect.height)
            n.drawInRect(rect, context: nil, withCurrentGraphicsContext: c)
        }
    }
}


