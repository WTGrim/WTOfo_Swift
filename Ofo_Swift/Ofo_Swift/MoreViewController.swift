//
//  MoreViewController.swift
//  Ofo_Swift
//
//  Created by Dwt on 2017/9/22.
//  Copyright © 2017年 Dwt. All rights reserved.
//

import UIKit
import WebKit

class MoreViewController: UIViewController , WKUIDelegate{

    var webView : WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "热门活动"
        
        let url = URL.init(string: "http://m.ofo.so/active.html")!
        let request = URLRequest(url: url as URL)
        webView = WKWebView(frame:CGRect(x:0, y:0, width:self.view.bounds.width, height:self.view.bounds.height))
        webView.uiDelegate = self
        webView.load(request)
        view.addSubview(webView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
