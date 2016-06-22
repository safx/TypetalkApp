//
//  ArrayDataSource.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2016/06/23.
//  Copyright © 2016年 Safx Developers. All rights reserved.
//

import Foundation

#if os(OSX)
    import Cocoa
    typealias TableViewDataSource = NSTableViewDataSource
    typealias TableView = NSTableView
#elseif os(iOS)
    import UIKit
    typealias TableViewDataSource = UITableViewDataSource
    typealias TableView = UITableView
    typealias TableViewCell = UITableViewCell
#endif


protocol CellDataSouce {
    associatedtype Model
    var model: Model? { get set }
}


class ArrayDataSource<T, Cell where Cell: CellDataSouce, Cell: UITableViewCell, T == Cell.Model>: NSObject, TableViewDataSource {
    var model = [T]()
    let identifier: String

    init(identifier: String) {
        self.identifier = identifier
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: TableView) -> Int {
        return 1
    }

    func tableView(tableView: TableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }

    func tableView(tableView: TableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! Cell
        cell.model = model[indexPath.row]
        return cell
    }

    func tableView(tableView: TableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

#if os(iOS)
    func tableView(tableView: TableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // TODO
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
#endif

    // MARK: - ViewModel Actions

    //func createTopicAction(topicName: String) -> Observable<CreateTopic.Response> {
    //  return model.createTopic(topicName)
    //}
}



