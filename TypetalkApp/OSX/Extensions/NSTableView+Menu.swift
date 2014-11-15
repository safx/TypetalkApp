//
//  NSTableView+Menu.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2015/02/22.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Cocoa

extension NSTableView {

    public override func menuForEvent(event: NSEvent) -> NSMenu? {
        let location = convertPoint(event.locationInWindow, fromView: nil)
        let row = rowAtPoint(location)
        if row >= 0 && event.type == .RightMouseDown {
            if !selectedRowIndexes.containsIndex(row) {
                selectRowIndexes(NSIndexSet(index: row), byExtendingSelection: false)
            }
        }
        return super.menuForEvent(event)
    }

    func updateRowsAtIndexes(indexes: NSIndexSet, withAnimation animationOptions: NSTableViewAnimationOptions) {
        removeRowsAtIndexes(indexes, withAnimation: animationOptions)
        insertRowsAtIndexes(indexes, withAnimation: animationOptions)
    }

    class func asIndexSet(array: [Int]) -> NSIndexSet {
        return array.reduce(NSMutableIndexSet()) { u, idx in
            u.addIndex(idx)
            return u
        }
    }

    class func update(tableView: NSTableView?, closure: (NSTableView) -> ()) {
        if let t = tableView {
            dispatch_async(dispatch_get_main_queue()) {
                t.beginUpdates()
                closure(t)
                t.endUpdates()
            }
        }
    }

    class func reloadData(tableView: NSTableView?, closure: (NSTableView) -> () = { t in ()}) {
        if let t = tableView {
            dispatch_async(dispatch_get_main_queue()) { () in
                t.reloadData()
                closure(t)
            }
        }
    }
}
