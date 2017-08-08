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
    
    // model property
    private var threads: Threads?
    private var threadItems = [ThreadItem]()
    
    private var tableBinding: TableBinding?
    private let refreshControl = UIRefreshControl()
    
    // api call control variables
    private var page = 1
    private var processing = false
    
    // hide status bar when hidesBarsOnSwipe = true
    // reference: https://stackoverflow.com/a/26007878
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnSwipe = true
        
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
        tableBinding?.events.tableReachBottom = { [weak self] in
            guard (self?.processing)! else {
                self?.getPosts()
                return
            }
        }
        
        // add pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh.")
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        getPosts() // api first call
    }
    
    private func getPosts() {
        let parameters: Parameters = [
            "page": self.page
        ]
        
        self.processing = true // mark api call processing
        ApiConnect.sharedInstance.getThreads(parameters: parameters) { json, error in
            self.processing = false // mark api call finished
            
            // stop table refreshing
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            // print("getPost() called!")
            
            if json != nil {
                let response: Dictionary = json?["response"] as! Dictionary<String, Any>
                
                self.threads = Threads(JSON: response)
                var newThreadItems: [ThreadItem]?
                
                if self.threads != nil {
                    self.title = self.threads?.category?.name // set title
                    // print("threadItems count = \(String(describing: self.threads!.items?.count ?? 0))")
                    
                    newThreadItems = self.threads!.items
                    // print(newThreadItems?.toJSONString(prettyPrint: true) ?? "null")
                }
                
                if newThreadItems != nil {
                    self.threadItems += newThreadItems!
                    self.tableBinding?.list = [self.threadItems]
                    self.tableBinding?.reload()
                    
                    self.page += 1 // update page value
                    print("page = \(self.page).")
                }
              
                
                //                print(threadItems?[0].createDate ?? "null")
                //                print(threads!.toJSONString(prettyPrint: true) ?? "")
                
                //                print(PostTitle(response).getProps())
                //                for (key, value) in response {
                //                    print("key = \(key), value = \(value)")
                //                }
                
                
                
            } else {
                // do something when no json
            }
        }
    } // end getPost()
    
    func refreshTable(sender: AnyObject) {
        self.page = 1 // reset page to 1
        self.threadItems.removeAll() // clear all saved threadItems
        getPosts()
    }
    
}

