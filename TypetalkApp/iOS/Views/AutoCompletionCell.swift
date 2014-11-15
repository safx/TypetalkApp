//
//  AutoCompletionCell.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2014/12/12.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import yavfl

class AutoCompletionCell : UITableViewCell {
    private var completionText = UILabel()
    private var completionDescription = UILabel()
    private var thumbnail = UIImageView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        thumbnail.image = nil
    }
    
    func setModel(model: CompletionDataSource.CompletionModel) {
        completionText.text = model.text
        completionText.textColor = model.online ? UIColor.blackColor() : UIColor.grayColor()
        completionDescription.text = model.description
        thumbnail.alpha = model.online ? 1 : 0.5
        
        if let url = model.imageURL {
            Alamofire.request(.GET, url)
                .response { (request, response, data, error) in
                    if error == nil {
                        self.thumbnail.image = UIImage(data: data as NSData)
                    }
            }
        }
    }

    private func setupView() {
        completionText.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        completionText.numberOfLines = 0
        
        completionDescription.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        completionDescription.textColor = UIColor.grayColor()

        for i in [completionText, completionDescription, thumbnail] {
            contentView.addSubview(i)
        }

        visualFormat(completionText, completionDescription, thumbnail) { completionText, desc, img in
            .H ~ |-[img,==32]-[completionText]-[desc]-| % .AlignAllCenterY
            .V ~ |-2-[img,==32]
        }

        updateConstraints()
    }
}

