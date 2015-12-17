//
//  AppDelegate.swift
//  TypetalkApp-OSX
//
//  Created by Safx Developer on 2015/02/01.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Cocoa
import TypetalkKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    override init() {
        TypetalkAPI.setDeveloperSettings(
            clientId:     "Your ClientID",
            clientSecret: "Your SecretID",
            redirectURI:  "Your custome scheme",
            scopes: [.my, .topic_post, .topic_read, .topic_write, .topic_delete])
        TypetalkAPI.restoreTokenFromAccountStore()
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
    }
    
    func applicationWillFinishLaunching(aNotification: NSNotification) {
        let appleEventManager:NSAppleEventManager = NSAppleEventManager.sharedAppleEventManager()
        appleEventManager.setEventHandler(self, andSelector: "handleGetURLEvent:replyEvent:",
            forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    
    // MARK - handleURL
    
    func handleGetURLEvent(event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        if let ev = event {
            if let url_str = ev.descriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue {
                if let url = NSURL(string: url_str) {
                    if TypetalkAPI.isRedirectURL(url) {
                        TypetalkAPI.authorizationDone(URL: url)
                    }
                }
            }
        }
    }

}

