//
//  EditTopicViewModel.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/22.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//


import Cocoa
import TypetalkKit
import ReactiveCocoa
import LlamaKit

class EditTopicViewModel: NSObject {
    private let model = TopicInfoDataSource()
    var accounts: ObservableProperty<[Account]> {
        return model.accounts
    }
    var invites: ObservableProperty<[TopicInvite]> {
        return model.invites
    }



    let teamList = ObservableProperty([TeamListItem]())
    let teamListIndex = ObservableProperty(0)

    let topicName = ObservableProperty("")
    var teamId = ObservableProperty(TeamID(-1))
    
    private(set) var oldTopicName: String = ""
    private(set) var oldTeamId: TeamID = -1

    // MARK: - Action

    func fetch(topic: Topic) {
        oldTopicName = topic.name
        topicName.put(topic.name)

        model.fetch(topic.id)
        model.teams.values
            .map { t -> TeamID in t.count == 0 ? -1 : t[0].team.id }
            .combineLatestWith(teamList.values)
            .start { (teamId, teams) in
                self.teamId.put(teamId)
                self.oldTeamId = teamId
                for i in 0..<teams.count {
                    if teams[i].id == teamId {
                        self.teamListIndex.put(i)
                        return
                    }
                }
            }

        Client.sharedClient.getTeams()
            .map { $0.teams }
            .filter { $0.count > 0 }
            .map { teams in
                var ts = teams.map { TeamListItem(team: $0) }
                ts.insert(TeamListItem(), atIndex: 0)
                return ts
            }
            .start { teamlist in
                self.teamList.put(teamlist)
            }
    }

    func deleteTopic() {
        model.deleteTopic(model.topic.value.id)
            .start()
    }

    func updateTopic() {
        let name = topicName.value
        let s = teamId.value
        if name == oldTopicName && s == oldTeamId { return }

        let t: TeamID? = s == -1 ? nil : s
        model.updateTopic(model.topic.value.id, name: name, teamId: t)
            .start()
    }

    // MARK: -

    @objc class TeamListItem : NSObject {
        let id: TeamID = -1
        let name = "(None)"
        let count = 0
        override var description: String {
            if id == -1 { return name }
            let p = count > 1 ? "s" : ""
            return "\(name) (\(count) member\(p))"
        }
        override init() {}
        init(team: TeamWithCount) {
            self.id = team.team.id
            self.name = team.team.name
            self.count = team.memberCount
        }
    }

}
