//
//  TableBindingWithRowHeight.swift
//  lihkgClient
//
//  Created by lung on 25/8/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import UIKit

class TableBindingWithRowHeight: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var events = TableBindingEvent()
    weak var tableView: UITableView?
    
    var list: [[Any]] // 2-dimensional array
    var tableRowHeight: CGFloat = 60 // default 60 row height
    
    var isScrolling = false {
        didSet {
            if !self.isScrolling {
                self.events.tableStopScrolling?()
            }
        }
    }
    
    init(tableView: UITableView, list: [[Any]] = [[Any]]()) {
        print("TableBinding init called.")
        self.tableView = tableView
        self.list = list
        self.isScrolling = false // trigger isScrolling event.
    }
    
    func setDataSource() {
        print("set data source.")
        tableView?.dataSource = self
        tableView?.delegate = self
    }
    
    func reload() {
        tableView?.reloadData()
    }
    
    func getRecord(indexPath: IndexPath) -> Any? {
        if list.count == 0 {
            return nil
        }
        return list[indexPath.section][indexPath.row]
    }
    
    func clearList() {
        list.removeAll()
        list = [[Any]]()
    }
    
    // ************* delegate functions *************
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //        print("number of sections.")
        return events.numOfSections?() ?? list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        print("number if rows in sections.")
        return events.numOfRows?(section) ?? list[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellHeight = events.heightForRow?(indexPath, getRecord(indexPath: indexPath)) ?? self.tableRowHeight
        // print("cellHeight : \(cellHeight)")
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return events.cellForRow?(indexPath, getRecord(indexPath: indexPath)) ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print("did select")
        events.rowSelected?(indexPath, getRecord(indexPath: indexPath))
    }
    
    
    // ************** scroll view delegate **************
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.isScrolling = true
        
        // calculates where the user is in the y-axis
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - scrollView.frame.size.height
        
        if offsetY >= contentHeight {
            // print("reach bottom.")
            events.tableReachBottom?()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isScrolling = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate && self.isScrolling {
            self.isScrolling = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.isScrolling {
            self.isScrolling = false
        }
    }
    
    deinit {
        print("TableBindingWithRowHeight dealloc.")
    }
    
}
