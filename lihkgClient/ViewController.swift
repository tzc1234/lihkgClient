//
//  ViewController.swift
//  lihkgClient
//
//  Created by lung on 22/7/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var tableView: ThreadTableView!
    private var threads: Threads? // model property
    private var tableBinding: TableBinding?
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register xib cell
        tableView.register(UINib.init(nibName: "ThreadCell", bundle: nil), forCellReuseIdentifier: "thread_cell")
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // set table binding
        tableBinding = TableBinding(tableView: tableView)
        tableBinding?.setDataSource()
        tableBinding?.events.cellForRow = { [weak self] indexPath, record in
            let cell = self?.tableView.dequeueReusableCell(withIdentifier: "thread_cell", for: indexPath) as! ThreadCell
            
            let threadItem = record as? ThreadItem
            if threadItem != nil {
                cell.setThreadItem(threadItem!)
            }
            
            return cell
        }
        
        // add pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh.")
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPosts()
    }
    
    private func getPosts() {
        let parameters: Parameters = [
            "page": 1
        ]
        
        ApiConnect.getThreads(parameters: parameters) { json, error in
            if json != nil {
                let response: Dictionary = json?["response"] as! Dictionary<String, Any>
                
                self.threads = Threads(JSON: response)
                if self.threads != nil {
                    // set title
                    self.title = self.threads?.category?.name
                    // print("threadItems count = \(String(describing: self.threads!.items?.count ?? 0))")
                }
                
                let threadItems = self.threads!.items
//                print(threadItems?.toJSONString(prettyPrint: true) ?? "null")
                
                if threadItems != nil {
                    self.tableBinding?.list = [threadItems!]
                    self.tableBinding?.reload()
                    print("set thread items and reload table called")
                }
                
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                
                
                
                //                print(threadItems?[0].createDate ?? "null")
                //                print(threads!.toJSONString(prettyPrint: true) ?? "")
                
                //                print(PostTitle(response).getProps())
                //                for (key, value) in response {
                //                    print("key = \(key), value = \(value)")
                //                }
                
                
                
            } else {
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                // do something when no json
            }
        }
    } // end getPost()
    
    func refreshTable(sender: AnyObject) {
        getPosts()
    }
    
}

