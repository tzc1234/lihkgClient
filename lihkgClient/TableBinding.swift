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
    var heightForRow: ((IndexPath) -> CGFloat)?
    var cellForRow: ((IndexPath, Any) -> UITableViewCell)?
}

class TableBinding: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var events = TableBindingEvent()
    weak var tableView: UITableView?
    
    var list: [[Any]] // 2-dimensional array
    var tableRowHeight: CGFloat = 90 // default 90 row height
    
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
    
    func getRecord(indexPath: IndexPath) -> Any {
        return list[indexPath.section][indexPath.row]
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
//        print("height for row at")
        return events.heightForRow?(indexPath) ?? tableRowHeight
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return events.cellForRow?(indexPath, getRecord(indexPath: indexPath)) ?? UITableViewCell()
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
