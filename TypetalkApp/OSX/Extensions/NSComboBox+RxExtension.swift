//
//  NSComboBox+RacExtension.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/23.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

extension NSComboBox {

    func rx_selectionSignal() -> Observable<Int> {
        let c = NSNotificationCenter.defaultCenter()
        return create { [weak self] observer in
            let obs = c.addObserverForName(NSComboBoxSelectionDidChangeNotification, object: self, queue: nil) { notification in
                if let s = self {
                    observer.onNext(s.indexOfSelectedItem)
                }
            }

            return AnonymousDisposable { c.removeObserver(obs) }
        }
    }

}