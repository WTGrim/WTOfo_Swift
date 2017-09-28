//
//  ViewController.swift
//  Ofo_Swift
//
//  Created by Dwt on 2017/9/22.
//  Copyright © 2017年 Dwt. All rights reserved.
//

import UIKit
import SWRevealViewController

class ViewController: UIViewController , MAMapViewDelegate, AMapSearchDelegate{

    //底部控制台
    @IBOutlet weak var panelView: UIView!
    var mapView:MAMapView!
    var search:AMapSearchAPI!
    var minePin:MinePinAnnotation!
    var minePinView:MAPinAnnotationView!
    var searchNear = true
    var currentAnnotations : [MAPointAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    //定位
    @IBAction func locationClick(_ sender: UIButton) {
        
        searchNearBike()
    }
    
}

//Mark:-自定义的相关方法
extension ViewController{
    
    fileprivate func setupUI() {
        navigationItem.titleView = UIImageView(image:UIImage.init(named: "Login_Logo_117x25_"))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor.black
        
        //高德地图
        mapView = MAMapView(frame:view.bounds)
        mapView.delegate = self
        mapView.zoomLevel = 17
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        view.addSubview(mapView)
        
        search = AMapSearchAPI()
        search.delegate = self
        
        view.bringSubview(toFront: panelView)
        
        if let revealVC = revealViewController(){
            revealVC.rearViewRevealWidth = 280
            navigationItem.leftBarButtonItem?.target = revealVC
            navigationItem.leftBarButtonItem?.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
    }
    
    //用餐馆模拟成小黄车
    fileprivate func searchCustomLocation(_ center:CLLocationCoordinate2D) {
        
        let request = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(center.latitude), longitude: CGFloat(center.longitude))
        request.keywords = "餐馆"
        request.radius = 600
        request.requireExtension = true
        search.aMapPOIAroundSearch(request)
    }
    
    //搜索周边小黄车
    fileprivate func searchNearBike() {
        searchCustomLocation(mapView.userLocation.coordinate)
    }
    
    
    //大头针动画
    fileprivate func pinAnimation() {
        
        let frame = minePinView.frame
        UIView.animate(withDuration: 0.6, animations: {
            self.minePinView.frame = frame.offsetBy(dx: 0, dy: -20)

        }) { (completed) in
            UIView.animate(withDuration: 0.6, animations: {
                self.minePinView.frame = frame
            })
        }
    }

}

//Mark:-相关代理
extension ViewController{
    
    
    //poi检索完成后的回调
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        
        guard response.count > 0 else {
            print("没有小黄车")
            return
        }
        
        var annotations : [MAPointAnnotation] = []
        annotations = response.pois.map{
            let annotation = MAPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees($0.location.latitude), longitude: CLLocationDegrees($0.location.longitude))
            if $0.distance < 50 {//红包车
                annotation.title = "红包区域开锁小黄车"
                annotation.subtitle = "骑行10分钟可获得现金红包"
            }else{
                annotation.title = "正常可用"
            }
            return annotation
        }
        
        //先删除当前的annotation
        mapView.removeAnnotations(currentAnnotations)
        currentAnnotations = annotations
        mapView.addAnnotations(annotations)
        if searchNear {//第一次搜索 显示地图缩放动画， 其他没有动画
            mapView.showAnnotations(annotations, animated: true)
            searchNear = !searchNear
        }
    }
    
    //自定义大头针
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        //用户的位置，不需要自定义
        if annotation is MAUserLocation{
            return nil
        }
        
        if annotation is MinePinAnnotation{//如果是我的位置
            let pinId = "minePin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: pinId) as? MAPinAnnotationView
            if pinView == nil{
                pinView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pinId)
            }
            pinView?.image = UIImage(named:"homePage_wholeAnchor_24x37_")
            pinView?.canShowCallout = false
            minePinView = pinView
            return pinView
        }
        
        let reuseId = "annotationId"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MAPinAnnotationView
        if annotationView == nil{
            annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        
        if annotation.title == "正常可用" {
            annotationView?.image = UIImage(named: "HomePage_nearbyBike_33x36_")
        }else{
            annotationView?.image = UIImage(named:"HomePage_nearbyBikeRedPacket_33x36_")
        }
        annotationView?.canShowCallout = true
        annotationView?.animatesDrop = true
        return annotationView
    }
    
    
    //地图初始化完成，设置用户位置大头针
    func mapInitComplete(_ mapView: MAMapView!) {
        
        minePin = MinePinAnnotation()
        minePin.coordinate = mapView.centerCoordinate
        minePin.lockedScreenPoint = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        minePin.isLockedToScreen = true
        mapView.addAnnotation(minePin)
        mapView.showAnnotations([minePin], animated: true)
    }
    
    //用户移动地图，重新搜索
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        
        if wasUserAction{
            minePin.isLockedToScreen = true
            pinAnimation()
            searchCustomLocation(mapView.centerCoordinate)
        }
    }
    
}

