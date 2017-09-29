//
//  ViewController.swift
//  Ofo_Swift
//
//  Created by Dwt on 2017/9/22.
//  Copyright © 2017年 Dwt. All rights reserved.
//

import UIKit
import SWRevealViewController
import FTIndicator

class ViewController: UIViewController , MAMapViewDelegate, AMapSearchDelegate, AMapNaviWalkManagerDelegate{

    //底部控制台
    @IBOutlet weak var functionView: UIView!
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var scanBtn: ScanButton!
    
    var controlPanelLayer:CAShapeLayer!
    var mapView:MAMapView!
    var search:AMapSearchAPI!
    var minePin:MinePinAnnotation!
    var minePinView:MAPinAnnotationView!
    var searchNear = true
    var currentAnnotations : [MAPointAnnotation] = []
    var start, end : CLLocationCoordinate2D!
    var walkManager : AMapNaviWalkManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    //定位
    @IBAction func locationClick(_ sender: UIButton) {
        
        searchNear = true
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
        
        walkManager = AMapNaviWalkManager()
        walkManager.delegate = self
        
        view.bringSubview(toFront: panelView)
        
        if let revealVC = revealViewController(){
            revealVC.rearViewRevealWidth = 280
            navigationItem.leftBarButtonItem?.target = revealVC
            navigationItem.leftBarButtonItem?.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
        
        //绘制控制面板
        controlPanelLayer = CAShapeLayer()
        controlPanelLayer.lineWidth = 1.0
        controlPanelLayer.fillColor = UIColor.white.cgColor
        
        let color = UIColor.white
        color.set()
        let path = UIBezierPath()
        path.lineWidth = 1.0
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.move(to: CGPoint(x: 0, y: panelView.bounds.height))
        path.addLine(to: CGPoint(x: 0, y: 40))
        path.addQuadCurve(to: CGPoint(x:panelView.bounds.width, y:40), controlPoint: CGPoint(x:panelView.bounds.width / 2.0, y:-40))
        path.addLine(to: CGPoint(x: panelView.bounds.width, y: panelView.bounds.height))
        path.close()
        path.fill()
        
        controlPanelLayer.path = path.cgPath
        controlPanelLayer.shadowOffset = CGSize(width: 0, height: -5)
        controlPanelLayer.shadowOpacity = 0.1
        controlPanelLayer.shadowColor = UIColor.black.cgColor
        panelView.layer.insertSublayer(controlPanelLayer, below: functionView.layer)
        
        scanBtn.addTarget(self, action: #selector(scanClick), for: .touchUpInside)
        scanBtn.layer.shadowOffset = CGSize(width: 4, height: 10)
        scanBtn.layer.shadowColor = UIColor(red: 217/255.0, green: 197/255.0, blue: 47/255.0, alpha: 1).cgColor
        scanBtn.layer.shadowOpacity = 0.2
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
        minePinView.frame = frame.offsetBy(dx: 0, dy: -20)
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
            self.minePinView.frame = frame
        }) { (completed) in
            
        }
    }
    
    @objc fileprivate func scanClick(){
        
        print("点击扫描")
        
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
//        annotationView?.animatesDrop = true
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
        
        //搜索
        searchNear = true
        searchNearBike()
    }
    
    //用户移动地图，重新搜索
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        
        if wasUserAction{
            mapView.removeOverlays(mapView.overlays)
            minePin.isLockedToScreen = true
            pinAnimation()
            searchCustomLocation(mapView.centerCoordinate)
        }
    }
    
    //添加地图标注动画
    func mapView(_ mapView: MAMapView!, didAddAnnotationViews views: [Any]!) {
        
        let views = views as! [MAAnnotationView]
        for view in views {
            guard view.annotation is MAPointAnnotation else{
                continue
            }
            
            view.transform = CGAffineTransform(scaleX: 0, y: 0)
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
                view.transform = .identity
            }, completion: { (completed) in
                
            })
        }
    }
    
    //选中标注
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        
        start = minePin.coordinate
        end  = view.annotation.coordinate
        
        let startPoint = AMapNaviPoint.location(withLatitude: CGFloat(start.latitude), longitude: CGFloat(start.longitude))!
        let endPoint  = AMapNaviPoint.location(withLatitude: CGFloat(end.latitude), longitude: CGFloat(end.longitude))!
        walkManager.calculateWalkRoute(withStart: [startPoint], end: [endPoint])
    }
    
    //绘制路线
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if overlay is MAPolyline{
            
            minePin.isLockedToScreen = false
            mapView.visibleMapRect = overlay.boundingMapRect
            let render = MAPolylineRenderer(overlay: overlay)
            render?.lineWidth = 4.0
            render?.strokeColor = UIColor.green
            return render
        }
        return nil
    }
    
    //Mark:-AMapNaviWalkViewDelegate 导航代理
    func walkManager(onCalculateRouteSuccess walkManager: AMapNaviWalkManager) {
       print("路线规划成功")
        
        var cordinates = walkManager.naviRoute!.routeCoordinates!.map {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees($0.latitude), longitude: CLLocationDegrees($0.longitude))
        }
        let polyline = MAPolyline(coordinates: &cordinates, count: UInt(cordinates.count))
        
        mapView.removeOverlays(mapView.overlays)
        mapView.add(polyline)
        
        //提示时间和距离
        let time = walkManager.naviRoute!.routeTime / 60
        var timeDes = "1分钟以内"
        if time > 0 {
            timeDes = time.description + "分钟"
        }
        
        let hintTitle = "步行" + timeDes
        let hintSubTitle  = "距离" + walkManager.naviRoute!.routeLength.description + "米"
        FTIndicator.setIndicatorStyle(.dark)
        FTIndicator.showNotification(with: UIImage(named:"clock_24x24_"), title: hintTitle, message: hintSubTitle)
    }
    
    func walkManager(_ walkManager: AMapNaviWalkManager, onCalculateRouteFailure error: Error) {
        print("路线规划失败",error)
    }
}

