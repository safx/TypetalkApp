//
//  String+Emoji.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/11.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation

extension String {

    private var emojiUnescapeRegExp : NSRegularExpression {
        struct Static {
            static let instance = NSRegularExpression(pattern: "|".join(emoji.keys.map{ ":\($0):" }), options: NSRegularExpressionOptions(0), error: nil)!
        }
        return Static.instance
    }
    
    var emojiEscapeRegExp : NSRegularExpression {
        struct Static {
            static let instance = NSRegularExpression(pattern: "|".join(emoji.values), options: NSRegularExpressionOptions(0), error: nil)!
        }
        return Static.instance
    }

    func emojiUnescape() -> String {
        var s = self as NSString
        let ms = emojiUnescapeRegExp.matchesInString(s, options: NSMatchingOptions(0), range: NSMakeRange(0, s.length))

        for m in reverse(ms) {
            let r = m.range
            let p = s.substringWithRange(r)
            let px = p.substringWithRange(Range<String.Index>(start: p.startIndex.successor(), end: p.endIndex.predecessor()))
            if let t = emoji[px] {
                s = s.stringByReplacingCharactersInRange(r, withString: t)
            }
        }
        return s
    }

    func emojiEscape() -> String {
        var s = self as NSString
        let ms = emojiEscapeRegExp.matchesInString(s, options: NSMatchingOptions(0), range: NSMakeRange(0, s.length))

        for m in reverse(ms) {
            let r = m.range
            let p = s.substringWithRange(r)
            let fs = filter(emoji, { (k,v) in v == p })
            if countElements(fs) > 0 {
                let kv = fs[0]
                s = s.stringByReplacingCharactersInRange(r, withString: ":\(kv.0):")
            }
        }
        return s
    }

}
