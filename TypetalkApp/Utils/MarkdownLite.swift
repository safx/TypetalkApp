//
//  MarkdownLite.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/04/18.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation
import Emoji

typealias ContextClosure = (CGContext -> ()) -> ()

#if os(iOS)
    import UIKit
    let verticalDirection = CGFloat(1.0)
    typealias EdgeInsets = UIEdgeInsets
    typealias Color = UIColor
    typealias Font = UIFont
    func WithCurrentGraphicsContext(height: CGFloat)(closure: CGContext -> ()) {
        let gfx = UIGraphicsGetCurrentContext()
        closure(gfx)
    }

#else
    import AppKit
    let verticalDirection = CGFloat(-1.0)
    typealias EdgeInsets = NSEdgeInsets
    typealias Color = NSColor
    typealias Font = NSFont
    func UIEdgeInsetsMake(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> EdgeInsets {
        return NSEdgeInsetsMake(top, left, bottom, right)
    }
    func UIEdgeInsetsInsetRect(rect: CGRect, insets: EdgeInsets) -> CGRect {
        return CGRectMake(CGRectGetMinX(rect) + insets.left,
            CGRectGetMinY(rect) + insets.top,
            CGRectGetWidth(rect) - insets.left - insets.right,
            CGRectGetHeight(rect) - insets.top - insets.bottom);
    }
    class NSStringDrawingContext {}
    extension NSAttributedString {
        func boundingRectWithSizeEx(size: CGSize, options: NSStringDrawingOptions, context: NSStringDrawingContext?) -> CGRect {
            return boundingRectWithSize(size, options: options)
        }
        func drawWithRect(rect: CGRect, options: NSStringDrawingOptions, context: NSStringDrawingContext?) {
            drawWithRect(rect, options: options)
        }
    }

    func WithCurrentGraphicsContext(height: CGFloat)(closure: CGContext -> ()) {
        let ctx = NSGraphicsContext.currentContext()!
        ctx.saveGraphicsState()

        let gfx = ctx.CGContext
        let xform = NSAffineTransform()
        xform.translateXBy(0, yBy: height - 12)
        xform.scaleXBy(1, yBy: -1)
        xform.concat()

        closure(gfx)

        ctx.restoreGraphicsState()
    }

#endif

let DefaultFont = Font.systemFontOfSize(15)
let FixedFont = Font(name: "Menlo", size: 14)!
let ParagraphMargin = UIEdgeInsetsMake(4, left: 4, bottom: 4, right: 4)
let QuoteMargin = UIEdgeInsetsMake(4, left: 12, bottom: 4, right: 4)
let QuotePadding = UIEdgeInsetsMake(0, left: 4, bottom: 0, right: 0)
let QuoteBorderColor = Color(white: 0.7, alpha: 1).CGColor
let QuoteLeftBorderWidth = CGFloat(2)
let CodeMargin = UIEdgeInsetsMake(4, left: 8, bottom: 4, right: 8)
let CodePadding = UIEdgeInsetsMake(4, left: 8, bottom: 4, right: 4)
let CodeBackgroundColor = Color(white: 0.9, alpha: 1).CGColor


func VerticalMargin(margin: EdgeInsets) -> CGFloat {
    return margin.top + margin.bottom
}

func VerticalMargin(margin1: EdgeInsets, margin2: EdgeInsets) -> CGFloat {
    return VerticalMargin(margin1) + VerticalMargin(margin2)
}

func HorizontalMargin(margin: EdgeInsets) -> CGFloat {
    return margin.left + margin.right
}

func HorizontalMargin(margin1: EdgeInsets, margin2: EdgeInsets) -> CGFloat {
    return HorizontalMargin(margin1) + HorizontalMargin(margin2)
}

enum MarkdownInline {
    case Link(String, NSURL?)
    case Text(String)
}

enum MarkdownBlock {
    case Document([MarkdownBlock])
    case Quote([MarkdownBlock])
    case Paragraph([MarkdownInline])
    case Code(String, String)
}

extension MarkdownInline {
    internal var attributedString: NSMutableAttributedString {
        switch self {
        case .Link(let (text, url)):
            var attrs: [String:AnyObject] = [
                NSFontAttributeName: DefaultFont,
                NSForegroundColorAttributeName: Color.blueColor(),
                NSUnderlineColorAttributeName: Color.blueColor(),
                NSUnderlineStyleAttributeName: 1
            ]
            if let u = url {
                attrs[NSLinkAttributeName] = u
                //attrs[NSToolTipAttributeName] = u.absoluteString
            }
            return NSMutableAttributedString(string: text.emojiUnescapedString, attributes: attrs)
        case .Text(let text):
            let attrs: [String:AnyObject] = [
                NSFontAttributeName: DefaultFont
            ]
            return NSMutableAttributedString(string: text.emojiUnescapedString, attributes: attrs)
        }
    }
}

extension MarkdownBlock {
    func getHeight(width: CGFloat) -> CGFloat {
        let size = CGSize(width: CGFloat(width), height: CGFloat.max)
        switch self {
        case .Document(let blocks):
            return blocks.reduce(0) { a, e in
                let h = e.getHeight(width)
                return a + h
            }
        case .Quote(let blocks):
            return blocks.reduce(0) { a, e in
                let h = e.getHeight(width - HorizontalMargin(QuoteMargin, margin2: QuotePadding))
                return a + h
                } + VerticalMargin(QuoteMargin, margin2: QuotePadding)
        case .Paragraph:
            let s = CGSize(width: width - HorizontalMargin(ParagraphMargin), height: CGFloat.max)
            let bounds = attributedString.boundingRectWithSizeEx(s, options: drawingOptions, context: nil)
            return bounds.height + VerticalMargin(ParagraphMargin)
        case .Code:
            let s = CGSize(width: width - HorizontalMargin(CodeMargin, margin2: CodePadding), height: CGFloat.max)
            let bounds = attributedString.boundingRectWithSizeEx(s, options: drawingOptions, context: nil)
            return bounds.height + VerticalMargin(CodeMargin, margin2: CodePadding)
        }
    }

    private var drawingOptions: NSStringDrawingOptions {
        return unsafeBitCast(NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue | NSStringDrawingOptions.UsesFontLeading.rawValue, NSStringDrawingOptions.self)
    }

    private var attributedString: NSMutableAttributedString {
        switch self {
        case .Code(let (code, lang)):
            let attrs: [String:AnyObject] = [
                NSFontAttributeName: FixedFont
            ]
            return NSMutableAttributedString(string: code, attributes: attrs)
        case .Paragraph(let inlines):
            let es = inlines.map { $0.attributedString }
            var a = NSMutableAttributedString()
            a.beginEditing()
            a = es.reduce(a) { a, e in
                a.appendAttributedString(e)
                return a
            }
            a.endEditing()
            return a
        default:
            fatalError("Code block expected")
        }
    }

    private func drawChildrenInRect(elements: [MarkdownBlock], rect: CGRect, withCurrentGraphicsContext: ContextClosure, context: NSStringDrawingContext?) {
        elements.reduce(CGFloat(0)) { top, elem in
            let offsetRect = rect.offsetBy(dx: 0, dy: top)
            elem.drawInRect(offsetRect, withCurrentGraphicsContext: withCurrentGraphicsContext, context: context)
            let height = elem.getHeight(rect.size.width)
            return top + height * verticalDirection
        }
    }

    func drawInRect(rect: CGRect, withCurrentGraphicsContext: ContextClosure, context: NSStringDrawingContext? = nil) {
        let height = self.getHeight(rect.size.width)

        switch self {
        case .Document(let blocks):
            drawChildrenInRect(blocks, rect: rect, withCurrentGraphicsContext: withCurrentGraphicsContext, context: context)
        case .Quote(let blocks):
            let rect1 = UIEdgeInsetsInsetRect(rect, insets: QuoteMargin)

            withCurrentGraphicsContext { gfx -> () in
                CGContextSetFillColorWithColor(gfx, QuoteBorderColor)
                let leftRect = CGRectMake(rect1.origin.x, verticalDirection * rect1.origin.y, QuoteLeftBorderWidth, height - VerticalMargin(QuoteMargin))
                CGContextFillRect(gfx, leftRect)
                ()
            }

            let rect2 = UIEdgeInsetsInsetRect(rect1, insets: QuotePadding)
            drawChildrenInRect(blocks, rect: rect2, withCurrentGraphicsContext: withCurrentGraphicsContext, context: context)
        case .Paragraph(let inlines):
            let r = UIEdgeInsetsInsetRect(rect, insets: ParagraphMargin)
            attributedString.drawWithRect(r, options: drawingOptions, context: context)
        case .Code(let (code, lang)):
            let rect1 = UIEdgeInsetsInsetRect(rect, insets: CodeMargin)

            withCurrentGraphicsContext { gfx -> () in
                CGContextSetFillColorWithColor(gfx, CodeBackgroundColor)
                let codeRect = CGRectMake(rect1.origin.x, verticalDirection * rect1.origin.y, rect1.size.width, height - VerticalMargin(CodeMargin))
                CGContextFillRect(gfx, codeRect)
                ()
            }
            
            let rect2 = UIEdgeInsetsInsetRect(rect1, insets: CodePadding)
            attributedString.drawWithRect(rect2, options: drawingOptions, context: context)
        }
    }
}

