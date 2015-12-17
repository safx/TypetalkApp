//
//  MarkdownAST.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/04/06.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation
//import MarkdownKit

@objc class MarkdownNode : NSObject {
    var contents: [NSObject] = [NSObject]()
    let type: UInt32 = 0

    init(type: UInt32) {
        self.type = type
    }

    override var description : String {
        var c = ""
        for var i = 0; i < contents.count; ++i {
            c += contents[i].description
        }

        if type >= HOEDOWN_NODE_BLOCK_LAST.rawValue {
            return "\(c)"
        }

        let t = { (type: UInt32) -> String in
            switch type {
            case HOEDOWN_NODE_DOCUMENT.rawValue      : return "body"
            case HOEDOWN_NODE_PARAGRAPH.rawValue     : return "p"
            case HOEDOWN_NODE_BLOCKCODE.rawValue     : return "pre"
            case HOEDOWN_NODE_BLOCKQUOTE.rawValue    : return "blockquote"
            default: fatalError()
            }
            }(type)

        return "<\(t)>\(c)</\(t)>"
    }

    func addObject(obj: NSObject) {
        contents.append(obj)
    }

    class func parse(markdownText: String) -> MarkdownNode {

        let asNode = { (p: UnsafeMutablePointer<Void>) -> MarkdownNode in
            return unsafeBitCast(p, MarkdownNode.self)
        }
        let asObj = { (p: UnsafeMutablePointer<Void>) -> NSObject in
            return unsafeBitCast(p, NSObject.self)
        }
        let asVoid = { (a: NSObject) -> UnsafeMutablePointer<Void> in
            return unsafeBitCast(a, UnsafeMutablePointer<Void>.self)
        }

        let renderer = MDKRenderer()

        let pool = NSMutableArray()

        renderer.block_new = { type in
            let a = MarkdownNode(type: type.rawValue)
            pool.addObject(a)
            return asVoid(a)
        }

        renderer.span_new = { type in
            let a = MarkdownNode(type: type.rawValue)
            pool.addObject(a)
            return asVoid(a)
        }

        renderer.block_free = { node, type in
            pool.removeObject(asObj(node))
        }
        renderer.span_free = { node, type in
            pool.removeObject(asObj(node))
        }

        renderer.blockcode = { node_, code, lang in
            let node = asNode(node_)

            let codeBlock = MarkdownNode(type: HOEDOWN_NODE_BLOCKCODE.rawValue)
            codeBlock.addObject(code)
            pool.addObject(codeBlock)

            node.addObject(codeBlock)
        }

        renderer.blockquote = { node_, cont in
            let node = asNode(node_)
            node.addObject(asObj(cont))
        }

        renderer.paragraph = { node_, cont in
            let node = asNode(node_)
            node.addObject(asObj(cont))
        }

        renderer.normal_text = { node_, text in
            let node = asNode(node_)
            node.addObject(text)
        }

        renderer.link = { (node_, content_, link, title) in
            let node = asNode(node_)
            var content = asObj(content_)
            if let a = content as? NSArray {
                if a.count > 0 {
                    if let s = a[0] as? NSString {
                        content = s
                    }
                }
            }
            let link = MarkdownLink(content: content, link: link, title: title)
            node.addObject(link)
            return 1
        }
        
        return asNode(renderer.parse(markdownText, extensions: HOEDOWN_EXT_FENCED_CODE))
    }
}


@objc class MarkdownLink : NSObject {
    let content: NSObject
    let link: NSString
    let title: NSString

    override var description : String {
        return "<a href=\"\(link)\">\(content)</a>"
    }

    init(content: NSObject, link: NSString, title: NSString) {
        self.content = content
        self.link = link
        self.title = title
    }
}

