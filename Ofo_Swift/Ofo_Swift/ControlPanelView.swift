//
//  ControlPanelView.swift
//  Ofo_Swift
//
//  Created by Dwt on 2017/9/28.
//  Copyright © 2017年 Dwt. All rights reserved.
//

import Foundation

class ControlPanelView: UIView {
    
    override func draw(_ rect: CGRect) {
        
        let color = UIColor.white
        color.set()
        
        let path = UIBezierPath()
        path.lineWidth = 1.0
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        path.move(to: CGPoint(x: 0, y: bounds.height))
        path.addLine(to: CGPoint(x: 0, y: 40))
        path.addQuadCurve(to: CGPoint(x:bounds.width, y:40), controlPoint: CGPoint(x:bounds.width / 2.0, y:-40))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        path.close()
        path.fill()
        
    }
    
}
