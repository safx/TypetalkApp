//
//  CreateTopicViewController.swift
//  TypetalkApp
//
//  Created by Safx Developer on 2014/11/12.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import UIKit
import TypetalkKit
import RxSwift


class CreateTopicViewController: UITableViewController {
    let viewModel = CreateTopicViewModel()

    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
                
        tableView.dataSource = viewModel
        viewModel.topicTitle.values
            .start {
                self.doneButton.enabled = !($0.isEmpty)
            }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK action
    
    @IBAction func createTopic(sender: AnyObject) {
        viewModel.createTopicAction()
            .start(
                next: { res in
                    println("\(res)")
                },
                error: { err in
                    println("\(err)")
                },
                completed:{
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
    }
    
    //MARK: Segue
    
    @IBAction func exitAction(segue: UIStoryboardSegue) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool {
        return true
    }
    
}
