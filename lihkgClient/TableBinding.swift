//
//  TableBinding.swift
//  lihkgClient
//
//  Created by lung on 4/8/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import UIKit

struct TableBindingEvent {
    var numOfSections: (() -> Int)?
    var numOfRows: ((Int) -> Int)?
    var heightForRow: ((IndexPath, Any?) -> CGFloat)?
    var cellForRow: ((IndexPath, Any?) -> UITableViewCell)?
    var tableReachBottom: (() -> Void)?
    var rowSelected: ((IndexPath, Any?) -> Void)?
    var estimatedHeightForRow: ((IndexPath) -> CGFloat)?
    
    var tableStopScrolling: (() -> Void)?
}

class TableBinding: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var events = TableBindingEvent()
    weak var tableView: UITableView?
    
    var list: [[Any]] // 2-dimensional array
    // var tableRowHeight: CGFloat = 90 // default 90 row height
    
    init(tableView: UITableView, list: [[Any]] = [[Any]]()) {
        print("TableBinding init called.")
        self.tableView = tableView
        self.list = list
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

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return events.heightForRow?(indexPath) ?? tableRowHeight
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return events.cellForRow?(indexPath, getRecord(indexPath: indexPath)) ?? UITableViewCell()
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print("did select")
        events.rowSelected?(indexPath, getRecord(indexPath: indexPath))
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return events.estimatedHeightForRow?(indexPath) ?? UITableViewAutomaticDimension
    }
    
    
    // ************** scroll view delegate **************
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // calculates where the user is in the y-axis
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - scrollView.frame.size.height
        
        if offsetY >= contentHeight {
            // print("reach bottom.")
            events.tableReachBottom?()
        }
    }
    
    deinit {
        print("TableBinding dealloc.")
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
