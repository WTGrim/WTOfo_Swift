//
//  ScanViewController.swift
//  Ofo_Swift
//
//  Created by Dwt on 2017/9/29.
//  Copyright © 2017年 Dwt. All rights reserved.
//

import UIKit
import swiftScan
import FTIndicator

class ScanViewController: LBXScanViewController {

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var openTorch: ScanButton!
    @IBOutlet weak var inputNo: ScanButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    var isFlashOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        
        if let result = arrayResult.first{
            let msg = result.strScanned
            FTIndicator.setIndicatorStyle(.dark)
            FTIndicator.showToastMessage(msg)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.bringSubview(toFront: bottomView)
        view.bringSubview(toFront: topView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }

}

extension ScanViewController{
    
    fileprivate func setupUI(){

        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        openTorch.addTarget(self, action: #selector(openTorchClick), for: .touchUpInside)
        inputNo.addTarget(self, action: #selector(inputNoClick), for: .touchUpInside)

        var style = LBXScanViewStyle()
        style.anmiationStyle = .NetGrid
        style.animationImage = UIImage(named:"qrcode_scan_full_net")
        scanStyle = style
    }
    
    @objc fileprivate func closeBtnClick(){
        dismiss(animated: true) {
            
        }
    }
    
    @objc fileprivate func openTorchClick(){
        print("打开手电筒")

        isFlashOn = !isFlashOn
        scanObj?.changeTorch()
        if isFlashOn{
            openTorch.setImage(UIImage(named:"btn_enableTorch_w_21x21_"), for: .normal)
        }else{
            openTorch.setImage(UIImage(named:"btn_unenableTorch_w_15x23_"), for: .normal)
        }
    }
    
    @objc fileprivate func inputNoClick(){
        print("手动输入车牌号")
    }
    
}


