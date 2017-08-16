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
    //private var threads: Threads?
    
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
        
        setTableBinding()
        
        // add pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh.")
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        // getPosts()
        
        // test code:
        HtmlTagConverter.sharedInstance.parseMsg()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showThreadContentSegue" {
            if let nextCon = segue.destination as? ThreadContentController {
                nextCon.threadItem = sender as? ThreadItem
            }
        }
    }
    
    private func setTableBinding() {
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
                // self?.getPosts() TODO temp comments
                return
            }
        }
        tableBinding?.events.rowSelected = { [weak self] _, record in
            self?.performSegue(withIdentifier: "showThreadContentSegue", sender: record)
        }
    }
    
    private func getPosts() {
        let parameters: Parameters = [
            "page": self.page
        ]
        
        self.processing = true // mark api call processing
        ApiConnect.sharedInstance.getThreads(parameters: parameters).responseObject(keyPath: "response")
        { [weak self] (response: DataResponse<Threads>) in
            
            self?.processing = false // mark api call finished
            
            // stop table refreshing
            if (self?.refreshControl.isRefreshing)! {
                self?.refreshControl.endRefreshing()
            }
            
            print("getPost() called!")
            
            switch response.result {
            case .success(let threads):
                self?.title = threads.category?.name // set title

                let newThreadItems = threads.items
                // print(newThreadItems?.toJSONString(prettyPrint: true) ?? "null")
                
                // print("threadItems count = \(String(describing: threads?.items?.count ?? 0))")
                
                if newThreadItems != nil {
                    //self.threadItems += newThreadItems!
                    
                    let previousList = self?.tableBinding?.list.first
                    if previousList != nil {
                        // append threadItems for endless load
                        let previousThreadItems = (previousList as! [ThreadItem]) + newThreadItems!
                        self?.tableBinding?.list = [previousThreadItems]
                    } else {
                        let previousThreadItems = newThreadItems!
                        self?.tableBinding?.list = [previousThreadItems]
                    }
                    
                    self?.tableBinding?.reload()
                    
                    // self.page += 1 // update page value
                    // print("page = \(self.page).")
                }
                
                
                //                print(threadItems?[0].createDate ?? "null")
                //                print(threads!.toJSONString(prettyPrint: true) ?? "")
                
                //                print(PostTitle(response).getProps())
                //                for (key, value) in response {
                //                    print("key = \(key), value = \(value)")
                //                }
                
            case .failure(let error):
                print(error)
            }
        }
    } // end getPost()
    
    func refreshTable(sender: AnyObject) {
        self.page = 1 // reset page to 1
        self.tableBinding?.clearList() // clear list
        getPosts()
    }
    
}

