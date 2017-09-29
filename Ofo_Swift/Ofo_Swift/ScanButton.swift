//
//  ScanButton.swift
//  Ofo_Swift
//
//  Created by Dwt on 2017/9/28.
//  Copyright © 2017年 Dwt. All rights reserved.
//

import Foundation

class ScanButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
 
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView!.center = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        titleLabel!.center = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        imageView!.center.y = imageView!.center.y - 15
        titleLabel!.center.y = titleLabel!.center.y + 15
    }
}
