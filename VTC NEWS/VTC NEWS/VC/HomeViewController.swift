//
//  HomeViewController.swift
//  VTC NEWS
//
//  Created by hưng hoàng on 10/7/20.
//  Copyright © 2020 hưng hoàng. All rights reserved.
//

import UIKit
import WebKit
import CoreLocation
//import GoogleCast

class HomeViewController: UIViewController {
    var refreshControl : UIRefreshControl?
    var locationManager: CLLocationManager?
    var latitude : Double?
    var longtitude : Double?
    var address : String?
    var locationModel : Location?
    var playerUrl : String?
    var webUrl : String?
    var urlOverLay : String?
    var orientation : String?
    var topUrl : String?
    var topHeight : Int?
    var isLive : Bool?

    var type : Int? = 0
    // radio
    var urlWvRadio : String?
    // cast
    var urlImage : String?
    var titleCast: String?
    var descriptionCast: String?
    
    @IBOutlet weak var mWebView: WKWebView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpWeb()
        initPullRefresh()
        setUpLocation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadWebView(_:)), name: NSNotification.Name("RELOAD_WEB_MAIN"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDeepLink(_:)), name: NSNotification.Name("DEEP_LINK"), object: nil)
        let castButton = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        castButton.tintColor = UIColor.gray
    }
    override func viewDidAppear(_ animated: Bool) {
        cast()
    }
    // MARK: - Method Support
    @objc func reloadDeepLink(_ noti: Notification) {
        guard let value = noti.userInfo?["value"] as? String else {
            return
        }
        
        let number = Int.random(in: 0 ..< 999999999)
        if let url = URL(string: AppConst.APP_URL + "?v=" + "\(number)" + "#\(value)"){
            let request = URLRequest(url: url)
            mWebView.load(request)
        }
    }
    
    @objc func reloadWebView(_ noti: Notification) {
        let number = Int.random(in: 0 ..< 999999999)
        var request = URLRequest(url: URL(string: AppConst.APP_URL + "?v=" + "\(number)")!)
        if let urlString = (noti.userInfo?["url"] as? String)?.replacingOccurrences(of: "https://appnow.tek4tv.vn", with: ""), let url = URL(string: AppConst.APP_URL + "?v=" + "\(number)" + "#\(urlString)")  {
            UserDefaults.standard.setValue(nil, forKey: "WEB_MAIN")
            UserDefaults.standard.synchronize()
            request = URLRequest(url: url)
            mWebView.load(request)
        }
    }
    
    func initPullRefresh(){
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        mWebView.scrollView.refreshControl = refreshControl
        mWebView.scrollView.refreshControl?.beginRefreshing()
    }
    
    @objc func didPullToRefresh(){
        mWebView.evaluateJavaScript("javascript:pullToRefresh();") {(result, error) in
            print (error as Any)
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.destination is DetailViewController){
            let vc = segue.destination as! DetailViewController
            vc.str_url = playerUrl
            vc.webUrl = self.webUrl
            vc.topUrl = topUrl
            vc.height = topHeight
            vc.isLive = isLive
            vc.type = type
            vc.urlImage = urlImage
            vc.titleCast = titleCast
            vc.descriptionCast = descriptionCast
            segue.destination.presentationController?.delegate = self
        }else if(segue.destination is PlayerViewController){
            let vc = segue.destination as! PlayerViewController
            vc.playerUrl = playerUrl
            vc.orientation = orientation
            vc.overlayUrl = urlOverLay
            vc.isLive = isLive
            vc.type = type
            segue.destination.presentationController?.delegate = self
        }else if(segue.destination is RadioViewController){
            let vc = segue.destination as! RadioViewController
            vc.webUrl = urlWvRadio
            segue.destination.presentationController?.delegate = self
        }
    }
}

extension HomeViewController : UIAdaptivePresentationControllerDelegate{
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        if let vc = presentationController.presentedViewController as? PlayerViewController{
            vc.actionPlayer()
        }else if let vc = presentationController.presentedViewController as? DetailViewController{
            vc.actionPlayer()
        }else if let vc = presentationController.presentedViewController as? RadioViewController{
            vc.actionPlayer()
        }
//        else if let vc = presentationController.presentedViewController as? ChannelsViewController{
//            vc.actionPlayer()
//        }
    }
}

extension HomeViewController : WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshControl?.endRefreshing()
    }
}

extension HomeViewController : CLLocationManagerDelegate{
    func setUpLocation(){
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways){
            locationManager?.startUpdatingLocation()
        }else{
            locationManager?.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.latitude =  locations.last?.coordinate.latitude
        self.longtitude = locations.last?.coordinate.longitude
        CLGeocoder().reverseGeocodeLocation((locations.last)!, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                return
            }else if let country = placemarks?.first?.country,
                let city = placemarks?.first?.locality {
                self.address = city
                self.locationModel = Location(address: self.address, latitude: self.latitude, longtitude: self.longtitude)
                //                self.sendLocationToWeb()
            }
            else {
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            locationManager?.startUpdatingLocation()
        case .authorizedWhenInUse:
            locationManager?.startUpdatingLocation()
        case .denied:
            print("user tap 'disallow' on the permission dialog, cant get location data")
        case .restricted:
            print("parental control setting disallow location data")
        case .notDetermined:
            print("the location permission dialog haven't shown before, user haven't tap allow/disallow")
        }
    }
}

extension HomeViewController:WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case AppConst.JS_GET_LOCATION_REQUEST:
            sendLocationToWeb()
        case AppConst.JS_SAVE_DATA_FROM_WEB_REQUEST:
            saveDataFromWeb(message.body as? NSDictionary)
        case AppConst.JS_PULL_TO_REFRESH_REQUEST:
            refresh()
        case AppConst.JS_GO_TO_FULL_REQUEST:
            gotoFullScreen(message.body as? NSDictionary)
        case AppConst.JS_LOAD_DATA_FROM_APP_REQUEST:
            sendDataToWeb()
        case AppConst.JS_GO_TO_DETAIL_REQUEST:
            gotoDetailScreen(message.body as? NSDictionary)
        case AppConst.JS_GO_TO_RADIO:
            goToRadio(message.body as? NSDictionary)
        case AppConst.JS_CAST:
            cast()
        default:
            print("some")
        }
    }
    
    func sendLocationToWeb()  {
        let jsonEncoder = JSONEncoder()
        if let loc = locationModel{
            let jsonData =  try? jsonEncoder.encode(loc)
            if let locationJson = jsonData{
                let json = String(data: locationJson, encoding: String.Encoding.utf8)
                if let json = json{
                    let js = "javascript:getLocation_return('\(json)');"
                    print(js)
                    mWebView.evaluateJavaScript(js) { (result,
                        error) in
                        print(error)
                    }
                }
            }else{
                print("error parse json")
            }
        }else{
            print("address nil")
        }
    }
    
    func saveDataFromWeb(_ dic : NSDictionary?){
        let data  = dic?["data"] as? String ?? ""
        let defaults = UserDefaults.standard
        defaults.set(data, forKey: AppConst.DefaultsKeys.KEY_DATA_FROM_WEB)
    }
    
    func refresh(){
        refreshControl?.beginRefreshing()
        mWebView.evaluateJavaScript(AppConst.JS_PULL_TO_REFRESH_REQUEST) { (result, error) in
            self.refreshControl?.endRefreshing()
        }
    }
    
    func cast() {
        NotificationCenter.default
            .post(name: NSNotification.Name("castScreen"),
                  object: nil)
        print("click")
    }

    
    func gotoFullScreen(_ dict : NSDictionary?){
        playerUrl = dict?["url"] as? String ?? ""
        urlOverLay = dict?["urloverlay"] as? String ?? ""
        orientation = dict?["isOriention"] as? String ?? ""
        isLive = dict?["isLive"] as? Bool ?? false
        type = dict?["type"] as? Int ?? 0
        performSegue(withIdentifier: "showFull", sender: nil)
    }
    func sendDataToWeb(){
        let defaults = UserDefaults.standard
        if let data = defaults.string(forKey: AppConst.DefaultsKeys.KEY_DATA_FROM_WEB){
            let js = "javascript:loadDataFromApp_return('\(data)');"
            mWebView.evaluateJavaScript(js) { (result, error) in
                print(error)
            }
        }
    }
    
    // gotoDetail
    func gotoDetailScreen(_ dict : NSDictionary?){
        playerUrl = dict?["url"] as? String ?? ""
        webUrl = dict?["urldetail"] as? String ?? ""
        topUrl = dict?["urlWvHeader"] as? String ?? ""
        topHeight = dict?["height"] as? Int ?? 0
        isLive = dict?["isLive"] as? Bool ?? false
        type = dict?["type"] as? Int ?? 0
        urlImage = dict?["urlImage"] as? String ?? ""
        titleCast = dict?["titleCast"] as? String ?? ""
        descriptionCast = dict?["descriptionCast"] as? String ?? ""
        performSegue(withIdentifier: "showDetail", sender: nil)
    }
    
    // goto Channels
    func gotoChannelScreen(_ dict : NSDictionary?){
        playerUrl = dict?["url"] as? String ?? ""
        webUrl = dict?["urldetail"] as? String ?? ""
        topUrl = dict?["urlWvHeader"] as? String ?? ""
        topHeight = dict?["height"] as? Int ?? 0
        isLive = dict?["isLive"] as? Bool ?? false
        type = dict?["type"] as? Int ?? 0
        performSegue(withIdentifier: "showChannels", sender: nil)
    }
    
    // goto Radio
    func goToRadio(_ dict : NSDictionary?){
        urlWvRadio = dict?["url"] as? String ?? ""
        performSegue(withIdentifier: "goToRadio", sender: nil)
    }
    
    func setUpWeb(){
        mWebView.configuration.userContentController.add(self, name: AppConst.JS_GET_LOCATION_REQUEST)
        mWebView.configuration.userContentController.add(self, name: AppConst.JS_SAVE_DATA_FROM_WEB_REQUEST)
        mWebView.configuration.userContentController.add(self, name: AppConst.JS_LOAD_DATA_FROM_APP_REQUEST)
        mWebView.configuration.userContentController.add(self, name: AppConst.JS_GO_TO_DETAIL_REQUEST)
        mWebView.configuration.userContentController.add(self, name: AppConst.JS_GO_TO_RADIO)
        mWebView.configuration.userContentController.add(self, name: AppConst.JS_GO_TO_FULL_REQUEST)
        mWebView.configuration.userContentController.add(self, name: AppConst.JS_CAST)
    }
}
extension HomeViewController: WKUIDelegate{
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        if( message != ""){
            if(message.contains("warning_")){
                showToast(message: message)
            }else{
                let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                    case .cancel:
                        print("cancel")
                    case .destructive:
                        print("destructive")
                    }}))
                self.present(alert, animated: true, completion: nil)
            }
        }
        completionHandler()
        
    }
}
extension UIViewController {
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.text = message.replacingOccurrences(of: "warning_", with: "")
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }

