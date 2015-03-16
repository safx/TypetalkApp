//
//  CreateNewMessageViewModel.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/03/07.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation
import TypetalkKit
import ReactiveCocoa
import LlamaKit

class CreateNewMessageViewModel {

    var parentViewModel: MessageListViewModel? = nil

    // MARK: - Action

    func postMessage(message: String) -> ColdSignal<PostMessageResponse> {
        return parentViewModel!.postMessage(message)
    }

}