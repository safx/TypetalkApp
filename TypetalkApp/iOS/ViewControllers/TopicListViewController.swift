//
//  TopicListViewController.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2014/11/08.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class TopicListViewController: UITableViewController {
    var messageListViewController: MessageListViewController? = nil
    private let viewModel = TopicListViewModel()
    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //self.navigationItem.leftBarButtonItem = self.editButtonItem()
        //let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNewTopic:")
        //self.navigationItem.rightBarButtonItem = addButton

        /*if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.messageListViewController = controllers[controllers.count-1].topViewController as? MessageListViewController
        }*/

        tableView.dataSource = viewModel
        viewModel.fetch(true)
            .observeOn(MainScheduler.sharedInstance)
            .subscribeNext { next in
                self.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addNewTopic(sender: AnyObject) {

    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let topic = viewModel.model.topics[indexPath.row] // FIXME
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! MessageListViewController
                controller.topic = topic
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "newTopic" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! CreateTopicViewController
            controller.viewModel.parentViewModel = viewModel
        }
    }
}
