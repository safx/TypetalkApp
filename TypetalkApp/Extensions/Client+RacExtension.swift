//
//  Client+RacExtension.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2014/11/08.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import Foundation
import TypetalkKit
import ReactiveCocoa
import LlamaKit
import Starscream


extension Client {

    private func _coldSignal<T>(callRestApi: ((T?, NSError?) -> Void) -> Void) -> ColdSignal<T> {
        let a = self._coldSignal_impl(callRestApi)
                    .deliverOn(QueueScheduler())
        let s = self.isSignedIn ? a : self.authorize(nil as T?).concat(a)
        return s.catch { err -> ColdSignal<T> in
            if err.domain == ERROR_DOMAIN || err.domain == NSURLErrorDomain {
                if err.code != 404 {
                    return self.requestRefreshToken(nil as T?).concat(a)
                }
            }
            return ColdSignal.error(err)
        }
    }

    private func _coldSignal_impl<T>(callRestApi: ((T?, NSError?) -> Void) -> Void) -> ColdSignal<T> {
        return ColdSignal { s, _ in
            callRestApi { (res: T?, err: NSError?) -> Void in
                if err == nil {
                    s.put(.Next(Box(res!)))
                    s.put(.Completed)
                } else {
                    println("ClientError: \(err)")
                    s.put(.Error(err!))
                }
            }
        }
    }

    public func getProfile() -> ColdSignal<GetProfileResponse> {
        return _coldSignal { s in self.getProfile(s) }
    }
    public func getTopics() -> ColdSignal<GetTopicsResponse> {
        return _coldSignal { s in self.getTopics(s) }
    }
    public func getMessages(topicId: TopicID, count: Int? = nil, from: PostID? = nil, direction: MessageDirection? = nil) -> ColdSignal<GetMessagesResponse> {
        return _coldSignal {
            s in self.getMessages(topicId, count: count, from: from, direction: direction, s)
        }
    }
    public func postMessage(topicId: TopicID, message: String, replyTo: PostID? = nil, fileKeys: [String] = [], talkIds: [TalkID] = []) -> ColdSignal<PostMessageResponse> {
        return _coldSignal { s in self.postMessage(topicId, message: message, replyTo: replyTo, fileKeys: fileKeys, talkIds: talkIds, completion: s) }
    }
    public func uploadAttachment(topicId: TopicID, fileName: String, fileContent: NSData) -> ColdSignal<UploadAttachmentResponse> {
        return _coldSignal { s in self.uploadAttachment(topicId, fileName: fileName, fileContent: fileContent, s) }
    }
    public func getTopicMembers(topicId: TopicID) -> ColdSignal<GetTopicMembersResponse> {
        return _coldSignal { s in self.getTopicMembers(topicId, s) }
    }
    public func getMessage(topicId: TopicID, postId: PostID) -> ColdSignal<GetMessageResponse> {
        return _coldSignal { s in self.getMessage(topicId, postId: postId, s) }
    }
    public func deleteMessage(topicId: TopicID, postId: PostID) -> ColdSignal<DeleteMessageResponse> {
        return _coldSignal { s in self.deleteMessage(topicId, postId: postId, s) }
    }
    public func likeMessage(topicId: TopicID, postId: PostID) -> ColdSignal<LikeMessageResponse> {
        return _coldSignal { s in self.likeMessage(topicId, postId: postId, s) }
    }
    public func unlikeMessage(topicId: TopicID, postId: PostID) -> ColdSignal<UnlikeMessageResponse> {
        return _coldSignal { s in self.unlikeMessage(topicId, postId: postId, s) }
    }
    public func favoriteTopic(topicId: TopicID) -> ColdSignal<FavoriteTopicResponse> {
        return _coldSignal { s in self.favoriteTopic(topicId, s) }
    }
    public func unfavoriteTopic(topicId: TopicID) -> ColdSignal<UnfavoriteTopicResponse> {
        return _coldSignal { s in self.unfavoriteTopic(topicId, s) }
    }
    public func getNotifications() -> ColdSignal<GetNotificationsResponse> {
        return _coldSignal { s in self.getNotifications(s) }
    }
    public func getNotificationStatus() -> ColdSignal<GetNotificationStatusResponse> {
        return _coldSignal { s in self.getNotificationStatus(s) }
    }
    public func openNotification() -> ColdSignal<OpenNotificationResponse> {
        return _coldSignal { s in self.openNotification(s) }
    }
    public func saveReadTopic(topicId: TopicID, postId: PostID? = nil) -> ColdSignal<SaveReadTopicResponse> {
        return _coldSignal { s in self.saveReadTopic(topicId, postId: postId, s) }
    }
    public func getMentions(from: MentionID? = nil, unread: Bool? = nil) -> ColdSignal<GetMentionsResponse> {
        return _coldSignal { s in self.getMentions(from, unread: unread, s) }
    }
    public func saveReadMention(mentionId: MentionID) -> ColdSignal<SaveReadMentionResponse> {
        return _coldSignal { s in self.saveReadMention(mentionId, s) }
    }
    public func acceptTeamInvite(teamId: TeamID, inviteId: InviteID) -> ColdSignal<AcceptTeamInviteResponse> {
        return _coldSignal { s in self.acceptTeamInvite(teamId, inviteId: inviteId, s) }
    }
    public func declineTeamInvite(teamId: TeamID, inviteId: InviteID) -> ColdSignal<DeclineTeamInviteResponse> {
        return _coldSignal { s in self.declineTeamInvite(teamId, inviteId: inviteId, s) }
    }
    public func acceptTopicInvite(teamId: TopicID, inviteId: InviteID) -> ColdSignal<AcceptTopicInviteResponse> {
        return _coldSignal { s in self.acceptTopicInvite(teamId, inviteId: inviteId, s) }
    }
    public func declineTopicInvite(teamId: TopicID, inviteId: InviteID) -> ColdSignal<DeclineTopicInviteResponse> {
        return _coldSignal { s in self.declineTopicInvite(teamId, inviteId: inviteId, s) }
    }
    public func createTopic(name: String, teamId: TeamID? = nil, inviteMembers: [String] = [], inviteMessage: String = "") -> ColdSignal<CreateTopicResponse> {
        return _coldSignal { s in self.createTopic(name, teamId: teamId, inviteMembers: inviteMembers, inviteMessage: inviteMessage, s) }
    }
    public func updateTopic(topicId: TopicID, name: String, teamId: TeamID? = nil) -> ColdSignal<UpdateTopicResponse> {
        return _coldSignal { s in self.updateTopic(topicId, name: name, teamId: teamId, s) }
    }
    public func deleteTopic(topicId: TopicID) -> ColdSignal<DeleteTopicResponse> {
        return _coldSignal { s in self.deleteTopic(topicId, s) }
    }
    public func getTopicDetails(topicId: TopicID) -> ColdSignal<GetTopicDetailsResponse> {
        return _coldSignal { s in self.getTopicDetails(topicId, s) }
    }
    public func inviteTopicMember(topicId: TopicID, inviteName: [String], inviteMessage: String) -> ColdSignal<InviteTopicMemberResponse> {
        return _coldSignal { s in self.inviteTopicMember(topicId, inviteName: inviteName, inviteMessage: inviteMessage, s) }
    }
    public func removeTopicMember(topicId: TopicID, removeInviteIds: [InviteID], removeMemberIds: [AccountID]) -> ColdSignal<RemoveTopicMemberResponse> {
        return _coldSignal { s in self.removeTopicMember(topicId, removeInviteIds: removeInviteIds, removeMemberIds: removeMemberIds, s) }
    }
    public func getTeams() -> ColdSignal<GetTeamsResponse> {
        return _coldSignal { s in self.getTeams(s) }
    }
    public func getFriends() -> ColdSignal<GetFriendsResponse> {
        return _coldSignal { s in self.getFriends(s) }
    }
    public func searchAccounts(nameOrEmailAddress: String) -> ColdSignal<SearchAccountsResponse> {
        return _coldSignal { s in self.searchAccounts(nameOrEmailAddress, s) }
    }
    public func getTalks(topicId: TopicID) -> ColdSignal<GetTalksResponse> {
        return _coldSignal { s in self.getTalks(topicId, s) }
    }
    public func getTalk(topicId: TopicID, talkId: TalkID, count: Int? = nil, from: PostID? = nil, direction: MessageDirection? = nil) -> ColdSignal<GetTalkResponse> {
        return _coldSignal { s in self.getTalk(topicId, talkId: talkId, count: count, from: from, direction: direction, s) }
    }
    public func donwloadAttachment(topicId: TopicID, postId: PostID, attachmentId: AttachmentID, filename: String, type: AttachmentType? = nil) -> ColdSignal<NSData> {
        return _coldSignal { s in self.downloadAttachment(topicId, postId: postId, attachmentId: attachmentId, filename: filename, type: type, s) }
    }
    public func downloadAttachmentWithURL(url: NSURL, type: AttachmentType? = nil) -> ColdSignal<NSData> {
        return _coldSignal { s in self.downloadAttachmentWithURL(url, type: type, s) }
    }
}

// MARK: auth

extension Client {

    private func authorize<T>(_: T?) -> ColdSignal<T> {
        return ColdSignal { s, _ in
            self.authorize { (err) -> Void in
                if err == nil {
                    s.put(.Completed)
                } else {
                    println("authError: \(err)")
                    s.put(.Error(err!))
                }
            }
        }
    }

    private func refreshToken<T>(_: T?) -> ColdSignal<T> {
        return ColdSignal<T> { s, _ in
            let ret = self.requestRefreshToken { (err) -> Void in
                if err == nil {
                    s.put(.Completed)
                } else {
                    println("refreshTokenError: \(err)")
                    s.put(.Error(err!))
                }
            }
        }
    }

    private func requestRefreshToken<T>(_: T?) -> ColdSignal<T> {
        let token_signal = self.isSignedIn ? refreshToken(nil as T?) : authorize(nil as T?)
        return token_signal.catch { err -> ColdSignal<T> in
            if err.domain == ERROR_DOMAIN || err.domain == NSURLErrorDomain {
                return self.authorize(nil as T?)
            }
            return ColdSignal.empty()
        }
    }
}

// MARK: WebSocket

extension Client {

    public var streamimgSignal : HotSignal<StreamingEvent> {
        struct Static {
            static let instance = Client.streamimgHotSignal(Client.sharedClient)
        }
        return Static.instance
    }
    private class func streamimgHotSignal(client: Client) -> HotSignal<StreamingEvent> {
        return Client.streamimgColdSignal(client)
            .deliverOn(QueueScheduler())
            .startMulticasted(nil)
    }

    private class func retryInterval(error: NSError) -> NSTimeInterval {
        return 10
    }

    private class func streamimgColdSignal(client: Client) -> ColdSignal<StreamingEvent> {
        return ColdSignal<StreamingEvent> { s, _ in
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
        .catch { err -> ColdSignal<StreamingEvent> in
            println("Streaming Error: \(err)")
            let delay: ColdSignal<StreamingEvent> = ColdSignal.empty()
                        .delay(Client.retryInterval(err), onScheduler: QueueScheduler())

            let s = Client.streamimgColdSignal(client)

            if err.domain == "Websocket" && err.code == 1 { // Invalid HTTP upgrade in Starscream
                // attempt to connect with HTTP first, and then upgrade to WebSocket
                return delay.then(Client.sharedClient.getNotificationStatus())
                            .then(s)
            }

            return delay.then(s)
        }
    }
}

