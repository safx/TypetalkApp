//
//  MessageCell.swift
//  iOSExample
//
//  Created by Safx Developer on 2014/09/26.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import UIKit
import TypetalkKit
import Alamofire
import RxSwift
import yavfl
import Emoji

class MessageCell: UITableViewCell {
    private let message = UILabel()
    private let lastUpdate = UILabel()
    private let accountName = UILabel()
    private let accountImage = UIImageView()
    private var thumbnailImages = [UIImageView]()
    private var constraint: NSLayoutConstraint?

    private let disposeBag = DisposeBag()

    var model: Post? {
        didSet { modelDidSet() }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func modelDidSet() {
        message.text = model!.message.emojiUnescapedString
        accountName.text = model!.account.name
        lastUpdate.text = model!.updatedAt.humanReadableTimeInterval
        
        let url = model!.account.imageUrl.absoluteString
        Alamofire.request(Alamofire.Method.GET, url)
            .rx_response()
            .observeOn(MainScheduler.sharedInstance)
            .subscribeNext { res in
                self.accountImage.image = UIImage(data: res)
            }
            .addDisposableTo(disposeBag)

        var prev: UIView = message
        for i in model!.attachments {
            if i.attachment.isImageFile {
                let thumbnail = UIImageView()
                thumbnail.contentMode = .ScaleAspectFit
                //let len = thumbnailImages.count
                self.contentView.addSubview(thumbnail)
                self.thumbnailImages.append(thumbnail)
                visualFormat(accountImage, prev, thumbnail) { img, prev, thumbnail in
                    .H ~ |-20-[thumbnail]-20-|;
                    .V ~ [img]-(>=4)-[thumbnail];
                    .V ~ [prev]-4-[thumbnail];
                    .V ~ [thumbnail,==200~250]
                }

                if let downloadRequest = DownloadAttachment(url: i.apiUrl, attachmentType: resolveAttachmentType(i)) {
                    let s = TypetalkAPI.request(downloadRequest)
                    s.subscribe(
                        onNext: { res in
                            print("** \(i.attachment.fileName)")
                            dispatch_async(dispatch_get_main_queue(), { () in
                                let img = UIImage(data: res)
                                thumbnail.image = img
                            })
                        },
                        onError: { err in
                            print("E \(err)")
                        },
                        onCompleted:{ () in
                        }
                    )
                    .addDisposableTo(disposeBag)
                    prev = thumbnail
                }
            } else {
                // FIXME
            }
        }
        
        constraint = NSLayoutConstraint(item: prev, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: -8)
        contentView.addConstraint(constraint!)
    }

    override func prepareForReuse() {
        for i in thumbnailImages {
            i.removeFromSuperview()
        }
        thumbnailImages.removeAll(keepCapacity: true)
        if let c = constraint {
            contentView.removeConstraint(c)
        }
    }
    
    private func resolveAttachmentType(a: URLAttachment) -> AttachmentType? {
        if let first = a.thumbnails.first {
            return first.type // FIXME
        }
        return nil
    }
    
    private func setupView() {
        message.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        message.numberOfLines = 0
        accountName.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        accountName.textColor = UIColor.blackColor()
        lastUpdate.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        lastUpdate.textColor = UIColor.grayColor()

        for i in [message, accountName, lastUpdate, accountImage] {
            contentView.addSubview(i)
        }

        visualFormat(message) { mes in
            .H ~ |-64-[mes]-8-|;
            .V ~ |-28-[mes]
        }

        visualFormat(lastUpdate, message, accountImage, accountName) { up, mes, img, name in
            .H ~ |-8-[img,==40]-16-[name];
            .H ~ [name]-8-[up] % .AlignAllBaseline;
            .V ~ |-4-[img,==40];
            .V ~ |-4-[name,==18]
        }

        updateConstraints()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
