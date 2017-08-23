//
//  ThreadContentController.swift
//  lihkgClient
//
//  Created by lung on 8/8/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import UIKit
import Alamofire

class ThreadContentController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func pressItem(_ sender: UIBarButtonItem) {
        firstCellSize()
    }
    
    weak var threadItem: ThreadItem?
    private var tableBinding: TableBinding?
    private let refreshControl = UIRefreshControl()
    
    // api call control variables
    private var page = 1
    private var processing = false
    private var isLastPage = false
    
    // hide status bar when hidesBarsOnSwipe = true
    // reference: https://stackoverflow.com/a/26007878
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = threadItem?.title
        
        // register xib cell
        tableView.register(UINib.init(nibName: "ThreadContentDataCell", bundle: nil), forCellReuseIdentifier: "ThreadContentDataCell")
        
        tableView.estimatedRowHeight = 66
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // set table binding
        tableBinding = TableBinding(tableView: tableView)
        tableBinding?.setDataSource()
        tableBinding?.events.cellForRow = { [weak self] indexPath, record in
            let cell = self?.tableView.dequeueReusableCell(withIdentifier: "ThreadContentDataCell", for: indexPath) as! ThreadContentDataCell
            
            let threadContentData = record as? ThreadContentData
            if threadContentData != nil {
                cell.setThreadContentData(threadContentData: threadContentData!)
            }
            
            return cell
        }
        tableBinding?.events.tableReachBottom = { [weak self] in
            if !(self?.processing)! && !(self?.isLastPage)! { // not processing and not last page
                self?.getThreadContent()
                return
            }
        }
        
        // add pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh.")
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func getThreadContent() {
        let parameters: Parameters = [
            "order": "reply_time"
        ]
        
        self.processing = true
        ApiConnect.sharedInstance.getThreadContent(threadId: ("370456" ?? threadItem?.threadId ?? ""), page: "\(page)", parameters: parameters).responseObject(keyPath: "response")
        { [weak self] (response: DataResponse<ThreadContent>) in
            
            // stop table refreshing
            if (self?.refreshControl.isRefreshing)! {
                self?.refreshControl.endRefreshing()
            }
            
            switch response.result {
            case .success(let threadContent): // not necessary reference threadContent
                //print(threadContent.toJSONString(prettyPrint: true) ?? "nil")
                
                let threadContentDataItems = threadContent.itemData
                if threadContentDataItems != nil {
                    
                    let previousDataItems = self?.tableBinding?.list.first
                    if previousDataItems != nil {
                        let newDataItems = (previousDataItems as! [ThreadContentData]) + threadContentDataItems!
                        self?.tableBinding?.list = [newDataItems]
                        print("appended.")
                    } else {
                        self?.tableBinding?.list = [threadContentDataItems!]
                        print("new.")
                    }
                    
                    self?.tableBinding?.reload()
                }
                
                self?.processing = false // getThreadContent() finished
                
                // define is the last page
                if (self?.page)! + 1 <= (threadContent.totalPage ?? 0) {
                    self?.page += 1 // add page count
                } else {
                    self?.isLastPage = true
                }
            
            case .failure(let error):
                self?.processing = false // getThreadContent() finished
                print(error)
            }
            
        }
    }
    
    func refreshTable(sender: AnyObject) {
        self.page = 1 // reset page to 1
        self.tableBinding?.clearList() // clear list
        getThreadContent()
    }
    
    func firstCellSize() {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath)
        print("cell msgLabel size : \((cell as! ThreadContentDataCell).msgLabel.frame.size)")
    }
    
    deinit {
        print("ThreadContentController dealloc.")
    }
}
