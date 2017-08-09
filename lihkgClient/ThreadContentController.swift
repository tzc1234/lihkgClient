//
//  ThreadContentController.swift
//  lihkgClient
//
//  Created by lung on 8/8/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import UIKit

class ThreadContentController: UIViewController {

    weak var threadItem: ThreadItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = threadItem?.title
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    deinit {
        print("ThreadContentController")
    }
}
