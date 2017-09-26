//
//  MenuController.swift
//  Ofo_Swift
//
//  Created by Dwt on 2017/9/26.
//  Copyright © 2017年 Dwt. All rights reserved.
//

import UIKit

class MenuController: UITableViewController {

    @IBOutlet weak var avator: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var identify: UILabel!
    @IBOutlet weak var credit: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }
}
