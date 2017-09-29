//
//  ScanViewController.swift
//  Ofo_Swift
//
//  Created by Dwt on 2017/9/29.
//  Copyright © 2017年 Dwt. All rights reserved.
//

import UIKit
import swiftScan

class ScanViewController: LBXScanViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }

}
