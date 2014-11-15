//
//  Alamofire+RacExtension.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/09.
//  Copyright (c) 2015 Safx Developers. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveCocoa
import LlamaKit

extension Alamofire.Request {
    public func rac_response() -> ColdSignal<NSData> {
        return ColdSignal { s, _ in
            self.response { (request: NSURLRequest, response: NSHTTPURLResponse?, object: AnyObject?, error: NSError?) -> Void in
                if let err = error {
                    s.put(.Error(err))
                } else {
                    if let data = object as? NSData {
                        s.put(.Next(Box(data)))
                    }
                    s.put(.Completed)
                }
            }
            return ()
        } .deliverOn(QueueScheduler())
    }
}