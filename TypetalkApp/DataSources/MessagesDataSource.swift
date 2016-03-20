//
//  MessagesDataSource.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2014/11/09.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import TypetalkKit
import RxSwift
import ObservableArray

class MessagesDataSource {
    typealias Event = ObservableArray<Post>.EventType

    let team = Variable(Team())
    let topic = Variable(Topic())
    let bookmark = Variable(Bookmark())
    var posts = ObservableArray<Post>()
    let hasNext = Variable(false)
    let bookmarkIndex = Variable<Int>(0)
    var observing = false

    let disposeBag = DisposeBag()

    // MARK: - Model ops

    func fetch(topicId: TopicID) {
        posts.removeAll()
        fetch_impl(topicId, from: nil)

        // FIXME: use queue
        if !observing {
            observing = true
            startObserving()
        }
    }

    func fetchMore(topicId: TopicID) {
        let len = posts.count
        let from: PostID? = len == 0 ? nil : posts[0].id

        fetch_impl(topicId, from: from)
    }
    
    private func fetch_impl(topicId: TopicID, from: PostID?) {
        let s = TypetalkAPI.rx_sendRequest(GetMessages(topicId: topicId, count:100, from: from))
        s.subscribe(
            onNext: { res in
                let firstFetch = self.posts.count == 0

                _ = res.team.flatMap { self.team.value = $0 }
                self.topic.value = res.topic
                self.posts.insertContentsOf(res.posts, atIndex: 0)
                self.hasNext.value = res.hasNext

                if firstFetch {
                    self.bookmark.value = res.bookmark
                    self.updateBookmarkIndex(self.bookmark.value.postId) // FIXME: change automatically
                }
            },
            onError: { err in
                print("E \(err)")
            },
            onCompleted:{ () in
            }
        )
        .addDisposableTo(disposeBag)
    }
    
    private func startObserving() {
        TypetalkAPI.rx_streamimg
        .subscribeNext { event in
            switch event {
            case .PostMessage(let res):   self.appendMessage(res.post!)
            case .DeleteMessage(let res): self.deleteMessage(res.post!)
            case .LikeMessage(let res):   self.addLikeMessage(res.like)
            case .UnlikeMessage(let res): self.removeLikeMessage(res.like)
            case .SaveBookmark(let res):  self.updateBookmark(res.unread)
            default: ()
            }
        }
        .addDisposableTo(disposeBag)
    }

    private func appendMessage(post: Post) {
        if post.topicId == topic.value.id {
            posts.append(post)
        }
    }

    private func find(topicId: TopicID, postId: PostID, closure: (Post, Int) -> ()) {
        if topicId != topic.value.id { return }

        for i in 0..<posts.count {
            if posts[i].id == postId {
                closure(posts[i], i)
                return
            }
        }
    }

    private func deleteMessage(post: Post) {
        find(post.topicId, postId: post.id) { post, i in
            self.posts.removeAtIndex(i)
            ()
        }
    }

    private func addLikeMessage(like: Like) {
        find(like.topicId, postId: like.postId) { post, i in
            self.posts[i] = self.posts[i] + like
        }
    }

    private func removeLikeMessage(like: Like) {
        find(like.topicId, postId: like.postId) { post, i in
            self.posts[i] = self.posts[i] - like
        }
    }

    private func updateBookmark(unread: Unread) {
        if unread.topicId == topic.value.id {
            let b = Bookmark(postId: unread.postId, updatedAt: bookmark.value.updatedAt)
            bookmark.value = b
            updateBookmarkIndex(b.postId) // FIXME: change automatically
        }
    }

    private func updateBookmarkIndex(postId: PostID) {
        find(topic.value.id, postId: postId) { post, idx in
            self.bookmarkIndex.value = idx
        }
    }

    // MARK: Acting to REST client

    func postMessage(message: String) -> Observable<PostMessage.Response>  {
        let id = topic.value.id
        return TypetalkAPI.rx_sendRequest(PostMessage(topicId: id, message: message, replyTo: nil, fileKeys: [], talkIds: []))
    }
}
