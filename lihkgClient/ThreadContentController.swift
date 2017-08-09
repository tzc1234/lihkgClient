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

    weak var threadItem: ThreadItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = threadItem?.title
        
        getThreadContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func getThreadContent() {
        let parameters: Parameters = [
            "order": "reply_time"
        ]
        
        ApiConnect.sharedInstance.getThreadContent(threadId: (threadItem?.threadId ?? ""), page: "1", parameters: parameters).responseObject(keyPath: "response")
        { [weak self] (response: DataResponse<ThreadContent>) in
            
            switch response.result {
            case .success(let threadContent):
                print(threadContent.toJSONString(prettyPrint: true) ?? "nil")
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    
    deinit {
        print("ThreadContentController")
    }
}
