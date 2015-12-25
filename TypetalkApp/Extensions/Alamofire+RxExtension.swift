//
//  Alamofire+RxExtension.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/09.
//  Copyright (c) 2015 Safx Developers. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift


extension Alamofire.Request {

    public func rx_response() -> Observable<NSData> {
        return create { observer in
            self.response { (request: NSURLRequest?, response: NSHTTPURLResponse?, object: AnyObject?, error: NSError?) -> Void in
                if let err = error {
                    observer.on(.Error(err))
                } else {
                    if let data = object as? NSData {
                        observer.on(.Next(data))
                    }
                    observer.on(.Completed)
                }
            }
            return AnonymousDisposable { self.cancel() }
        }
        .observeOn(SerialDispatchQueueScheduler(globalConcurrentQueuePriority: .Default))
    }

}