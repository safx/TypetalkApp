//
//  AttachmentView.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/08.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Cocoa
import TypetalkKit
import yavfl
import RxSwift

class AttachmentView: NSView {
    private var thumbnailImage: NSImageView?
    private var iconImage: NSImageView?
    private var fileInfoLabel: NSXLabel?

    private let disposeBag = DisposeBag()

    private(set) var model: URLAttachment? {
        didSet { modelDidSet() }
    }

    init(attachment: URLAttachment) {
        super.init(frame: NSMakeRect(0, 0, 0, 0)) // FIXME:RX
        self.model = attachment
        modelDidSet()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func modelDidSet() {
        if let m = model {
            if m.attachment.isImageFile {
                thumbnailImage = NSImageView()
                //thumbnail.contentMode = .ScaleAspectFit
                self.addSubview(thumbnailImage!)
                visualFormat(thumbnailImage!) { thumbnail in
                    .H ~ |-0-[thumbnail]-0-|;
                    .V ~ |-0-[thumbnail]-0-|;
                }

                if let downloadRequest = DownloadAttachment(url: m.apiUrl, attachmentType: AttachmentView.resolveAttachmentType(m)) {
                    let s = TypetalkAPI.request(downloadRequest)
                    s.subscribe(
                        onNext: { res in
                            Swift.print("** \(m.attachment.fileName)")
                            dispatch_async(dispatch_get_main_queue(), { () in
                                self.thumbnailImage!.image = NSImage(data: res)
                            })
                        },
                        onError: { err in
                            Swift.print("E \(err)")
                        },
                        onCompleted:{ () in
                    })
                    .addDisposableTo(disposeBag)
                }
            } else {
                fileInfoLabel = NSXLabel()
                let name = m.attachment.fileName
                let size = NSByteCountFormatter.stringFromByteCount(Int64(m.attachment.fileSize), countStyle: .File)
                let attr = [
                    NSForegroundColorAttributeName: NSColor.blueColor(),
                    NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
                ]
                let text = NSAttributedString(string: "\(name) (\(size))", attributes: attr)
                fileInfoLabel?.attributedStringValue = text
                self.addSubview(fileInfoLabel!)
                visualFormat(fileInfoLabel!) { label in
                    .H ~ |-64-[label]-0-|;
                    .V ~ |-0-[label]-0-|;
                }
                
            }
        }
    }

    class func viewHeight(a: URLAttachment) -> Int {
        let margin = 8
        if !a.thumbnails.isEmpty {
            return a.thumbnails[0].height + margin
        }
        return a.attachment.isImageFile ? 200 : 30 + margin
    }
    
    class private func resolveAttachmentType(a: URLAttachment) -> AttachmentType? {
        if !a.thumbnails.isEmpty {
            return a.thumbnails[0].type // FIXME
        }
        return nil
    }
}
