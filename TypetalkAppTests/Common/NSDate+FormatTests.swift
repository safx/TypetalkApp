//
//  NSDate+FormatTests.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2014/11/16.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import Foundation
import XCTest

class NSDate_FormatTests: XCTestCase {
    
    // TODO: check other locales
    func testHumanReadableTimeInterval() {
        let now = NSDate()
        
        XCTAssertEqual("1 minute ago", now.humanReadableTimeInterval(now))
        XCTAssertEqual("5 minutes ago", now.humanReadableTimeInterval(NSDate(timeInterval: -60*5, sinceDate: now)))
        
        XCTAssertEqual("1 hour ago", now.humanReadableTimeInterval(NSDate(timeInterval: -60*60*1, sinceDate: now)))
        XCTAssertEqual("1 hour ago", now.humanReadableTimeInterval(NSDate(timeInterval: -60*60*1.5, sinceDate: now)))
        XCTAssertEqual("3 hours ago", now.humanReadableTimeInterval(NSDate(timeInterval: -60*60*3, sinceDate: now)))
        
        XCTAssertEqual("1 day ago", now.humanReadableTimeInterval(NSDate(timeInterval: -60*60*24, sinceDate: now)))
        XCTAssertEqual("1 day ago", now.humanReadableTimeInterval(NSDate(timeInterval: -60*60*25, sinceDate: now)))
        XCTAssertEqual("2 days ago", now.humanReadableTimeInterval(NSDate(timeInterval: -60*60*24*2, sinceDate: now)))
        
        XCTAssertEqual("Jan 3 1970", now.humanReadableTimeInterval(NSDate(timeIntervalSince1970: 60*60*24*2)))
    }
    
}
