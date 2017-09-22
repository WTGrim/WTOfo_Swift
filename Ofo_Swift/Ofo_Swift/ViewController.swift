//
//  ViewController.swift
//  Ofo_Swift
//
//  Created by Dwt on 2017/9/22.
//  Copyright © 2017年 Dwt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = UIImageView(image:UIImage.init(named: "Login_Logo_117x25_"))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor.black
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

