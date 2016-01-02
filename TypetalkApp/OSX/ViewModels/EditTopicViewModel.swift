//
//  EditTopicViewModel.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/22.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//


import Cocoa
import TypetalkKit
import RxSwift


class EditTopicViewModel: NSObject {
    private let model = TopicInfoDataSource()
    private let disposeBag = DisposeBag()

    var accounts: Variable<[Account]> {
        return model.accounts
    }

    var invites: Variable<[TopicInvite]> {
        return model.invites
    }

    let teamList = Variable([TeamListItem]())
    let teamListIndex = Variable(0)

    let topicName = Variable("")
    var teamId = Variable(TeamID(-1))
    
    private(set) var oldTopicName: String = ""
    private(set) var oldTeamId: TeamID = -1

    // MARK: - Action

    func fetch(topic: Topic) {
        oldTopicName = topic.name
        topicName.value = topic.name

        model.fetch(topic.id)

        let ids = model.teams
            .asObservable()
            .map { t -> TeamID in
                t.count == 0 ? -1 : t[0].team.id
            }

        Observable.combineLatest(ids, teamList.asObservable()) { ($0, $1) }
            .subscribeNext { (teamId, teams) in
                self.teamId.value = teamId
                self.oldTeamId = teamId
                for (idx, team) in teams.enumerate() {
                    if team.id == teamId {
                        self.teamListIndex.value = idx
                        return
                    }
                }
            }
            .addDisposableTo(disposeBag)

        TypetalkAPI.rx_sendRequest(GetTeams())
            .map { $0.teams }
            .filter { $0.count > 0 }
            .map { teams in
                let ts = teams.map { TeamListItem(team: $0) }
                return [TeamListItem()] + ts
            }
            .bindTo(self.teamList)
            .addDisposableTo(disposeBag)
    }

    func deleteTopic() {
        model.deleteTopic(model.topic.value.id)
            .subscribe()
            .addDisposableTo(disposeBag)
    }

    func updateTopic() {
        let name = topicName.value
        let s = teamId.value
        if name == oldTopicName && s == oldTeamId { return }

        let t: TeamID? = s == -1 ? nil : s
        model.updateTopic(model.topic.value.id, name: name, teamId: t)
            .subscribe()
            .addDisposableTo(disposeBag)
    }

    // MARK: -

    @objc class TeamListItem : NSObject {
        var id: TeamID = -1
        var name = "(None)"
        var count = 0
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
