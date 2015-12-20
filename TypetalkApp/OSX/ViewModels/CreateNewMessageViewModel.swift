//
//  CreateNewMessageViewModel.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/03/07.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation
import TypetalkKit
import RxSwift

class CreateNewMessageViewModel {

    internal var parentViewModel: MessageListViewModel? = nil

    // MARK: - Action

    func postMessage(message: String) -> Observable<PostMessageResponse> {
        return parentViewModel!.postMessage(message)
    }

}