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
import ReSwift
import TypetalkKit


class TopicListViewController: UITableViewController, StoreSubscriber {
    var messageListViewController: MessageListViewController? = nil
    //private let viewModel = TopicListViewModel()
    private let disposeBag = DisposeBag()

    private let dataSource = ArrayDataSource<TopicWithUserInfo, TopicCell>(identifier: "TopicCell")

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

        tableView.dataSource = dataSource
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) { () -> Void in
            appStore.rx_dispatch(fetchTypetalkGetTopics)
                    .addDisposableTo(self.disposeBag)
        }
        appStore.subscribe(self) { state in
            state.topics
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        appStore.unsubscribe(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addNewTopic(sender: AnyObject) {

    }

    // MARK: - ReSwift

    func newState(state: [TopicWithUserInfo]?) {
        guard let state = state else { return }

        dataSource.model = state
        dispatch_async(dispatch_get_main_queue()) { [weak self] () -> Void in
            self?.tableView.reloadData()
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let topic = dataSource.model[indexPath.row] // FIXME
                appStore.dispatch(ViewTopic(topic: topic))
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! MessageListViewController
                //controller.topic = topic
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "newTopic" {
            //let controller = (segue.destinationViewController as! UINavigationController).topViewController as! CreateTopicViewController
            //controller.viewModel.parentViewModel = viewModel
        }
    }
}


