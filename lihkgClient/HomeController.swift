//
//  HomeController.swift
//  lihkgClient
//
//  Created by lung on 22/7/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

/*
import UIKit
import ObjectMapper

class HomeController: UIViewController {
    
    // model property
    private var threads: Threads?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        self.view.backgroundColor = UIColor.gray
        
        // init table binding
//        let tableBinding = TableBinding()
//        tableBinding.events.numOfRows = {
//            return $0 * 10
//        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        getPosts()
    }
    
    private func getPosts() {
        ApiConnect.getThreads() { json, error in
            if json != nil {
                //print("json = \(json!)")
                
                let response: Dictionary = json?["response"] as! Dictionary<String, Any>
//                print(response)
                
                self.threads = Threads(JSON: response)
                let threadItems = self.threads!.items
                print(threadItems?.toJSONString(prettyPrint: true) ?? "null")
                
                
//                print(threadItems?[0].createDate ?? "null")
//                print(threads!.toJSONString(prettyPrint: true) ?? "")
                
//                print(PostTitle(response).getProps())
//                for (key, value) in response {
//                    print("key = \(key), value = \(value)")
//                }
                
                
            }
            
        }
    } // end getPost()
    
}
*/








