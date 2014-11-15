//
//  NSComboBox+RacExtension.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/23.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Cocoa
import ReactiveCocoa
import LlamaKit

extension NSComboBox {

    func rac_selectionSignal() -> ColdSignal<Int> {
        let c = NSNotificationCenter.defaultCenter()
        return ColdSignal { [weak self] sink, disposable in
            let observer = c.addObserverForName(NSComboBoxSelectionDidChangeNotification, object: self, queue: nil) { notification in
                if let s = self {
                    sink.put(.Next(Box(s.indexOfSelectedItem)))
                }
            }

            disposable.addDisposable {
                c.removeObserver(observer)
            }
        }
    }

}