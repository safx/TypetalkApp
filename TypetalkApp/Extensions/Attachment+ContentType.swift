//
//  Attachment+ContentType.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/03.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation
import TypetalkKit

extension Attachment {
    
    var isImageFile: Bool {
        let ct = self.contentType
        if ct.hasPrefix("image/") { return true }
    
        let l = self.fileName.lowercaseString
        return ct == "application/octet-stream" &&
            l.hasSuffix("png") ||
            l.hasSuffix("gif") ||
            l.hasSuffix("jpg")
    }
}
