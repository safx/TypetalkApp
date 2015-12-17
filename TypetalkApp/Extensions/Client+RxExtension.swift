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

    static func request<T: APIKitRequest>(request: T) -> Observable<T.Response> {
        let a = requestImpl(request)
                //.subscribeOn(...)
        let s = isSignedIn ? a : authorize().concat(a)
        return s.catchError { error -> Observable<T.Response> in
            return requestRefreshToken(nil as T.Response?).concat(a)

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
    }
}

// MARK: OAuth

extension TypetalkAPI {

    private static func authorize<T>(_: T? = nil) -> Observable<T> {
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

    private static func refreshToken<T>(_: T? = nil) -> Observable<T> {
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

    private static func requestRefreshToken<T>(_: T?) -> Observable<T> {
        let token_signal = isSignedIn ? refreshToken(nil as T?) : authorize()
        return token_signal.catchError { error -> Observable<T> in
            return authorize(nil as T?)
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

    /*static public var streamimgSignal : Observable<StreamingEvent> {
        struct Static {
            static let instance = Client.streamimg(Client.sharedClient)
        }
        return Static.instance
    }
    private class func streamimgHotSignal(client: Client) -> Observable<StreamingEvent> {
        return Client.streamimgObservable(client)
            .deliverOn(QueueScheduler())
            .startMulticasted(nil)
    }

    private class func retryInterval(error: NSError) -> NSTimeInterval {
        return 10
    }

    private class func streamimgObservable(client: Client) -> Observable<StreamingEvent> {
        return Observable<StreamingEvent> { s, _ in
            client.streaming { ev in
                switch ev {
                case .Disconnected(let err):
                    if let e = err {
                        s.put(.Error(e))
                    } else {
                        s.put(.Completed)
                    }
                case .Connected:
                    println("connected")
                    fallthrough
                default:
                    dump(ev)
                    s.put(.Next(Box(ev)))
                }
            }
            return
        }
        .`catch` { err -> Observable<StreamingEvent> in
            println("Streaming Error: \(err)")
            let delay: Observable<StreamingEvent> = Observable.empty()
                        .delay(Client.retryInterval(err), onScheduler: QueueScheduler())

            let s = Client.streamimgObservable(client)

            if err.domain == "Websocket" && err.code == 1 { // Invalid HTTP upgrade in Starscream
                // attempt to connect with HTTP first, and then upgrade to WebSocket
                return delay.then(Client.sharedClient.getNotificationStatus())
                            .then(s)
            }

            return delay.then(s)
        }
    }*/
}

