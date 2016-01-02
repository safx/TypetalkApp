//
//  Client+RxExtension.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2014/11/08.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import Foundation
import APIKit
import TypetalkKit
import RxSwift

import Starscream


typealias TopicInvite = Invite // FIXME:RX

extension TypetalkAPI {

    static func rx_sendRequest<T: APIKitRequest>(request: T) -> Observable<T.Response> {
        let a = requestImpl(request)
        let s = isSignedIn ? a : authorize().concat(a)
        return s.catchError { error -> Observable<T.Response> in
            return requestRefreshToken().concat(a)

            /*let err = error as NSError
            if err.domain == ERROR_DOMAIN || err.domain == NSURLErrorDomain {
                if err.code != 404 {
                    return requestRefreshToken(nil as T.Response?).concat(a)
                }
            }
            return failWith(error)*/
        }
    }

    private static func requestImpl<T: APIKitRequest>(request: T) -> Observable<T.Response> {
        return create { observer in
            self.sendRequest(request) { result in
                switch result {
                case .Failure(let error):
                    observer.on(.Error(error))
                case .Success(let response):
                    observer.on(.Next(response))
                    observer.on(.Completed)
                }
            }
            return AnonymousDisposable { self.cancelRequest(T) }
        }
        .observeOn(SerialDispatchQueueScheduler(globalConcurrentQueuePriority: .Default))
    }
}

// MARK: OAuth

extension TypetalkAPI {

    private static func authorize<T>() -> Observable<T> {
        return create { observer in
            authorize { (err) -> Void in
                if let err = err {
                    print("authError: \(err)")
                    observer.on(.Error(err))
                } else {
                    observer.on(.Completed)
                }
            }
            return AnonymousDisposable { }
        }
    }

    private static func refreshToken<T>() -> Observable<T> {
        return create { observer in
            requestRefreshToken { (err) -> Void in
                if let err = err {
                    print("refreshTokenError: \(err)")
                    observer.on(.Error(err))
                } else {
                    observer.on(.Completed)
                }
            }
            return AnonymousDisposable { }
        }
    }

    private static func requestRefreshToken<T>() -> Observable<T> {
        let token_signal: Observable<T> = isSignedIn ? refreshToken() : authorize()
        return token_signal.catchError { error -> Observable<T> in
            return authorize()
            /*let err = error as NSError
            if err.domain == ERROR_DOMAIN || err.domain == NSURLErrorDomain {
                return authorize(nil as T?)
            }
            return failWith(error)*/
        }
    }
}

// MARK: WebSocket

extension TypetalkAPI {

    static var rx_streamimg : Observable<StreamingEvent> {
        struct Static {
            static let instance = TypetalkAPI.streamimgObservableImpl()
                .retryWhen { (errors: Observable<ErrorType>) in
                    return errors
                        .flatMapWithIndex{ error, retryCount -> Observable<Int64> in
                            let err = error as NSError

                            let c = TypetalkAPI.retryInterval(err, count: retryCount)
                            let s = SerialDispatchQueueScheduler(globalConcurrentQueuePriority: .Low)

                            if err.domain == "Websocket" && err.code == 1 { // Invalid HTTP upgrade in Starscream
                                // attempt to connect with HTTP first, and then retry (i.e., upgrade to WebSocket)
                                let reconnect = TypetalkAPI.rx_sendRequest(GetNotificationStatus()).map { _ in
                                    return Int64(0)
                                }

                                return timer(c, s)
                                    .ignoreElements() // surpress emitting from timer
                                    .concat(reconnect)
                            }

                            return timer(c, s)
                    }
            }
            .observeOn(SerialDispatchQueueScheduler(globalConcurrentQueuePriority: .Default))
        }
        return Static.instance
    }

    static private var sharedPublishSubject: PublishSubject<StreamingEvent> {
        struct Static {
            static let instance = PublishSubject<StreamingEvent>()
        }
        return Static.instance
    }

    private class func streamimgObservableImpl() -> PublishSubject<StreamingEvent> {
        let subject = sharedPublishSubject
        streaming { ev in
            switch ev {
            case .Disconnected(let err):
                if let e = err {
                    subject.on(.Error(e))
                } else {
                    subject.on(.Completed)
                }
            case .Connected:
                print("connected")
                fallthrough
            default:
                dump(ev)
                subject.on(.Next(ev))
            }
        }
        return subject
    }

    private class func retryInterval(error: NSError, count: Int) -> NSTimeInterval {
        return NSTimeInterval(10 + count * 5)
    }
}

