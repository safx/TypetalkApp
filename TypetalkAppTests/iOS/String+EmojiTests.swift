//
//  String+EmojiTests.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/11.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation
import XCTest

class String_EmojiTests: XCTestCase {

    func testEmojiUnescape() {
        XCTAssertEqual("", "".emojiUnescape())
        XCTAssertEqual("apple", "apple".emojiUnescape())
        XCTAssertEqual(":xxx:", ":xxx:".emojiUnescape())
        XCTAssertEqual("\u{1f34e}", ":apple:".emojiUnescape())

        XCTAssertEqual(":apxple\u{1f34e}", ":apxple:apple:".emojiUnescape())
        XCTAssertEqual("\u{1f34e}apple:", ":apple:apple:".emojiUnescape())
        XCTAssertEqual("\u{1f34e}\u{1f37a}", ":apple::beer:".emojiUnescape())

        XCTAssertEqual(":apxple\u{1f37a}", ":apxple\u{1f37a}".emojiUnescape())
        XCTAssertEqual("\u{1f34e}\u{1f37a}", ":apple:\u{1f37a}".emojiUnescape())
        XCTAssertEqual("\u{1f37a}\u{1f34e}", "\u{1f37a}:apple:".emojiUnescape())
        XCTAssertEqual("\u{1f34e}house\u{1f37a}", ":apple:house:beer:".emojiUnescape())
    }

    func testEmojiEscape() {
        XCTAssertEqual("", "".emojiEscape())
        XCTAssertEqual("apple", "apple".emojiEscape())
        XCTAssertEqual(":xxx:", ":xxx:".emojiEscape())
        XCTAssertEqual(":apple:", "\u{1f34e}".emojiEscape())

        XCTAssertEqual(":apxple:apple:", ":apxple\u{1f34e}".emojiEscape())
        XCTAssertEqual(":apple:apple:", "\u{1f34e}apple:".emojiEscape())
        XCTAssertEqual(":apple::beer:", "\u{1f34e}\u{1f37a}".emojiEscape())

        XCTAssertEqual(":apxple:apple:", ":apxple:apple:".emojiEscape())
        XCTAssertEqual(":apxple:apple:", ":apxple\u{1f34e}".emojiEscape())
        XCTAssertEqual(":apple::beer:", ":apple:\u{1f37a}".emojiEscape())
        XCTAssertEqual(":beer::apple:", "\u{1f37a}:apple:".emojiEscape())
        XCTAssertEqual(":apple:house:beer:", ":apple:house:beer:".emojiEscape())
    }
}
