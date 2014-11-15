//
//  MessagesDataSource.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2014/11/09.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import TypetalkKit
import ReactiveCocoa

class MessagesDataSource {
    typealias Signal = ObservableArray<Post>.Signal

    let team = ObservableProperty(Team())
    let topic = ObservableProperty(Topic())
    let bookmark = ObservableProperty(Bookmark())
    let posts = ObservableArray<Post>()
    let hasNext = ObservableProperty(false)
    let bookmarkIndex = ObservableProperty<Int>(0)
    var observing = false

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
        let s = Client.sharedClient.getMessages(topicId, count:100, from: from)
        s.start(
            next: { res in
                let firstFetch = self.posts.count == 0

                self.team.put(res.team)
                self.topic.put(res.topic)
                self.posts.splice(res.posts, atIndex: 0)
                self.hasNext.put(res.hasNext)

                if firstFetch {
                    self.bookmark.put(res.bookmark)
                    self.updateBookmarkIndex(self.bookmark.value.postId) // FIXME: change automatically
                }
            },
            error: { err in
                println("E \(err)")
            },
            completed:{ () in
            }
        )
    }
    
    private func startObserving() {
        let s = Client.sharedClient.streamimgSignal
        s.observe { event in
            switch event {
            case .PostMessage(let res):   self.appendMessage(res.post!)
            case .DeleteMessage(let res): self.deleteMessage(res.post!)
            case .LikeMessage(let res):   self.addLikeMessage(res.like)
            case .UnlikeMessage(let res): self.removeLikeMessage(res.like)
            case .SaveBookmark(let res):  self.updateBookmark(res.unread)
            default: ()
            }
        }
    }

    private func appendMessage(post: Post) {
        if post.topicId == topic.value.id {
            posts.append(post)
        }
    }

    private func find(topicId: TopicID, postId: PostID, closure: (Post, Int) -> ()) {
        if topicId != topic.value.id { return }

        for var i = 0; i < countElements(posts); ++i {
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
            bookmark.put(b)
            updateBookmarkIndex(b.postId) // FIXME: change automatically
        }
    }

    private func updateBookmarkIndex(postId: PostID) {
        find(topic.value.id, postId: postId) { post, idx in
            self.bookmarkIndex.put(idx)
        }
    }

    // MARK: Acting to REST client

    func postMessage(message: String) -> ColdSignal<PostMessageResponse>  {
        let id = topic.value.id
        return Client.sharedClient.postMessage(id, message: message, replyTo: nil, fileKeys: [], talkIds: [])
    }
}
