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
    private var tableBinding: TableBindingWithRowHeight?
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
    
    // temporary save the cells' indexPath ready for reload
    private var cellIndexPaths = [IndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = threadItem?.title
        
        // add notification observer
        NotificationCenter.default.addObserver(self, selector: #selector(ThreadContentController.collectReadyToReloadCellIndexPath(notification:)), name: Notification.Name("reloadThreadContentDataCell"), object: nil)
        
        // register xib cell
        tableView.register(UINib.init(nibName: "ThreadContentDataCell", bundle: nil), forCellReuseIdentifier: "ThreadContentDataCell")
        
        // set table binding
        tableBinding = TableBindingWithRowHeight(tableView: tableView)
        tableBinding?.setDataSource()
        tableBinding?.events.cellForRow = { [weak self] indexPath, record in
            let cell = self?.tableView.dequeueReusableCell(withIdentifier: "ThreadContentDataCell", for: indexPath) as! ThreadContentDataCell
            
            let threadContentData = record as? ThreadContentData
            if threadContentData != nil {
                threadContentData?.htmlTagConverter?.cellIndexPath = indexPath
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
        tableBinding?.events.heightForRow = { indexPath, record in
            let defaultCellHeight: CGFloat = 66
            let threadContentData = record as? ThreadContentData
            if threadContentData != nil {
                return threadContentData?.htmlTagConverter?.getExpectedCellHeight() ?? defaultCellHeight
            } else {
                return defaultCellHeight
            }
        }
        tableBinding?.events.tableStopScrolling = { [weak self] in
            while !(self?.cellIndexPaths.isEmpty)! {
                let path = self?.cellIndexPaths.removeLast()
                if (self?.tableView.indexPathsForVisibleRows?.contains(path!))! {
                    self?.tableView.reloadRows(at: [path!], with: .none)
                }
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
        let parameters: Parameters = ["order": "reply_time"]
        
        self.processing = true
        ApiConnect.sharedInstance.getThreadContent(threadId: (threadItem?.threadId ?? ""), page: "\(page)", parameters: parameters).responseObject(keyPath: "response")
        { [weak self] (response: DataResponse<ThreadContent>) in
            
            // stop table refreshing
            if (self?.refreshControl.isRefreshing)! {
                self?.refreshControl.endRefreshing()
            }
            
            switch response.result {
            case .success(let threadContent):
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
    
    func collectReadyToReloadCellIndexPath(notification: Notification) {
        if let path = notification.object as? IndexPath {
            // append different indexPath in self.cellIndexPaths
            if !self.cellIndexPaths.contains(path) {
                self.cellIndexPaths.append(path)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("reloadThreadContentDataCell"), object: nil)
        print("ThreadContentController dealloc.")
    }
}
