//
//  ViewController.swift
//  lihkgClient
//
//  Created by lung on 22/7/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: ThreadTableView!
    private var threads: Threads? // model property
    private var tableBinding: TableBinding?

    var flag = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Init Controller"
        
        // register xib cell
        tableView.register(UINib.init(nibName: "ThreadCell", bundle: nil), forCellReuseIdentifier: "thread_cell")
        
        // set table binding
        tableBinding = TableBinding(tableView: tableView)
        tableBinding?.setDataSource()
        
        tableBinding?.events.cellForRow = { [weak self] indexPath, record in
            let cell = self?.tableView.dequeueReusableCell(withIdentifier: "thread_cell", for: indexPath) as! ThreadCell
            
            if (self?.flag)! {
                print("change background to black color.")
                cell.backgroundColor = UIColor.black
                self?.flag = false
            }
            
            let threadItem = record as? ThreadItem
//            print("thread item")
//            print(threadItem?.title ?? "nil thread item.")
            cell.titleLabel.text = threadItem?.title
            
            return cell
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPosts()
    }
    
    private func getPosts() {
        ApiConnect.getThreads() { json, error in
            if json != nil {
                let response: Dictionary = json?["response"] as! Dictionary<String, Any>
                
                self.threads = Threads(JSON: response)
                let threadItems = self.threads!.items
//                print(threadItems?.toJSONString(prettyPrint: true) ?? "null")
                
                if threadItems != nil {
                    self.tableBinding?.list = [threadItems!]
                    self.tableBinding?.reload()
                    
                    print("set thread items called")
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
    
}

