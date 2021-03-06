//
//  TopicCell.swift
//  iOSExample
//
//  Created by Safx Developer on 2014/09/26.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import UIKit
import TypetalkKit

class TopicCell: UITableViewCell {
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var lastUpdate: UILabel!
    
    var model: TopicWithUserInfo? {
        didSet {
            name.text = model!.topic.name
            lastUpdate.text = model!.topic.updatedAt.humanReadableTimeInterval
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
