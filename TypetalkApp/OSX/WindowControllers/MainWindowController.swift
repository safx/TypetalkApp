//
//  MainWindowController.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/10.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.titleVisibility = .Hidden
        window?.styleMask |= NSFullSizeContentViewWindowMask
        window?.titlebarAppearsTransparent = true
    }

}
