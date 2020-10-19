//
//  DetailViewController.swift
//  VTC NEWS
//
//  Created by hưng hoàng on 10/7/20.
//  Copyright © 2020 hưng hoàng. All rights reserved.
//



import UIKit
import WebKit
import CoreMedia
import AVFoundation
import GoogleInteractiveMediaAds
//import GoogleCast

class DetailViewController: UIViewController {
    var str_url : String!
    var webUrl : String!
    var topUrl : String?
    var height : Int?
    var frame : CGRect?
    var isFull = false
    var isLive :Bool?
    var type : Int? = 0
    var urlCast: String?
    // cast
    var urlImage : String?
    var titleCast: String?
    var descriptionCast: String?
    // control
    var playerControl: PlayerControlView?
    
    @IBOutlet weak var playerView: Player!
    @IBOutlet weak var heightCT: NSLayoutConstraint!
    @IBOutlet weak var mWebView: WKWebView!
    @IBOutlet weak var mTop: WKWebView!
    
    static var kTestAppAdTagUrl =
    "http://api.vtcnow.vn/ads.ashx?v=ios"
    
    var contentPlayhead: IMAAVPlayerContentPlayhead?
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager!
    
//    var sessionManager: GCKSessionManager!
//    var deviceManager: GCKDevice!
    var mediaView: UIView!
//    private var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController!
    var des: String = "Cảm ơn bạn đã sử dụng"
    var titleMovie: String = "Nội dung được phát hành từ VTC NOW"
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(isLive, forKey: "isLive")
        if(type != 0){
            DetailViewController.kTestAppAdTagUrl = DetailViewController.kTestAppAdTagUrl + "?p" + "\(String(describing: type))"
        }
        setUpTop()
        if(str_url != nil && str_url != ""){
            UIApplication.shared.isIdleTimerDisabled = true
            playerView.isHidden = false
            setupPlayer()
        }else{
            playerView.isHidden = true
        }
        self.view.layoutIfNeeded()
        
        if(webUrl != nil && webUrl != ""){
            setUpWeb()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.shareLinkNotification(notification:)), name: Notification.Name("shareLink"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.shareScreenNotification(notification:)), name: Notification.Name("castScreen"), object: nil)
        // cast
//        setUpCast()
        customerControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override public var traitCollection: UITraitCollection {
        if UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.orientation.isPortrait {
            return UITraitCollection(traitsFrom:[UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }
    //MARK: - Method support
    
    @objc func shareLinkNotification(notification: Notification) {
        share()
    }
//    @objc func shareScreenNotification(notification: Notification) {
//        castScreen()
//    }
    
//    func setUpCast() {
//        sessionManager = GCKCastContext.sharedInstance().sessionManager
//        sessionManager.add(self)
//        mediaView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 70 - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!, width: self.view.frame.width, height: 70))
//        self.view.addSubview(mediaView!)
//        let castContext = GCKCastContext.sharedInstance()
//        miniMediaControlsViewController = castContext.createMiniMediaControlsViewController()
//        miniMediaControlsViewController.delegate = self
//        updateControlBarsVisibility(shouldAppear: true)
//        //        installViewController(miniMediaControlsViewController, inContainerView: mediaView!)
//    }
//    func installViewController(_ viewController: UIViewController?, inContainerView containerView: UIView) {
//        if let viewController = viewController {
//            addChild(viewController)
//            viewController.view.frame = containerView.bounds
//            containerView.addSubview(viewController.view)
//            viewController.didMove(toParent: self)
//        }
//    }
//    func updateControlBarsVisibility(shouldAppear: Bool = false) {
//        if shouldAppear {
//            mediaView!.isHidden = false
//        } else {
//            //                mediaView!.isHidden = true
//        }
//        UIView.animate(withDuration: 1, animations: { () -> Void in
//            self.view.layoutIfNeeded()
//        })
//        view.setNeedsLayout()
//    }
    // cast
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
    func castScreen() {
//        let url = URL.init(string: str_url)
//        print("link cast là: \(str_url ?? "")")
//        guard let mediaURL = url else {
//            print("invalid mediaURL")
//            return
//        }
//        let metadata = GCKMediaMetadata()
//        metadata.setString(titleMovie, forKey: kGCKMetadataKeyTitle)
//        metadata.setString(des,forKey: kGCKMetadataKeySubtitle)
//        metadata.addImage(GCKImage(url: URL(string: "https://scontent.fhph1-1.fna.fbcdn.net/v/t1.0-9/84208556_2491292227755355_5135490819574202368_o.png?_nc_cat=1&_nc_sid=85a577&_nc_ohc=FQMK0LsHP_MAX-vJdHl&_nc_ht=scontent.fhph1-1.fna&oh=7ab281a98fb4a4d1c3ee51b9e2162b48&oe=5FA47410")!,
//                                   width: 480,
//                                   height: 360))
//        let mediaInfoBuilder = GCKMediaInformationBuilder.init(contentURL: mediaURL)
//        mediaInfoBuilder.streamType = GCKMediaStreamType.unknown;
//        mediaInfoBuilder.contentType = "video/mp4"
//        mediaInfoBuilder.metadata = metadata;
//        let mediaInformation = mediaInfoBuilder.build()
//
//        if let request = sessionManager.currentSession?.remoteMediaClient?.loadMedia(mediaInformation) {
//            request.delegate = self
//        }
        //        GCKCastContext.sharedInstance().presentDefaultExpandedMediaControls()
    }
    
    func customerControl() {
        if isLive == true {
            playerView?.hideControl()
        } else if isLive == false {
            playerView?.unHideControl()
        }
    }
    func setUpTop(){
        if(topUrl != nil && topUrl != ""){
            mTop.backgroundColor = UIColor.white
            mTop.isHidden = false
            let request = URLRequest(url: URL(string: topUrl!)!)
            heightCT.constant = CGFloat(height!)
            mTop.layoutIfNeeded()
            mTop.uiDelegate = self
            mTop.configuration.userContentController.add(self, name: AppConst.JS_SAVE_DATA_FROM_WEB_REQUEST)
            mTop.configuration.userContentController.add(self, name: AppConst.JS_LOAD_DATA_FROM_APP_REQUEST)
            mTop.configuration.userContentController.add(self, name: AppConst.JS_BACK_PRESS)
            mTop.load(request)
            mTop.scrollView.showsHorizontalScrollIndicator = false
            mTop.scrollView.showsVerticalScrollIndicator = false
        }else{
            height = 0
            heightCT.constant = CGFloat(height!)
            mTop.layoutIfNeeded()
            mTop.uiDelegate = self
            mTop.isHidden = true
        }
    }
    
    func onBackPress(){
        str_url = ""
        playerView.pause()
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUpWeb(){
        //        let urlEncode = (webUrl ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = URL(string: webUrl ?? "") {
            mWebView.backgroundColor = UIColor.white
            let request = URLRequest(url: url)
            mWebView.uiDelegate = self
            mWebView.load(request)
            mWebView.scrollView.showsHorizontalScrollIndicator = false
            mWebView.scrollView.showsVerticalScrollIndicator = false
            mWebView.configuration.userContentController.add(self, name: AppConst.JS_SAVE_DATA_FROM_WEB_REQUEST)
            mWebView.configuration.userContentController.add(self, name: AppConst.JS_LOAD_DATA_FROM_APP_REQUEST)
            mWebView.configuration.userContentController.add(self, name: AppConst.JS_BACK_PRESS)
        }
    }
    // MARK: - Player and Ads
    func setupPlayer(){
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: playerView?.playerLayer?.player)
        //        self.playerView.delegate = self
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(DetailViewController.contentDidFinishPlaying(_:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: playerView.playerLayer?.player);
        
        playerView.backBlock = { [unowned self] (isFullScreen) in
            if isFullScreen == true {
                return
            }
            let _ = self.navigationController?.popViewController(animated: true)
        }
        showContentPlayer()
        setUpAdsLoader()
    }
    
    func setUpAdsLoader() {
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader.delegate = self
    }
    
    func requestAds() {
        // Create ad display container for ad rendering.
        //        let adDisplayContainer = IMAAdDisplayContainer(adContainer: self.Player)
        
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: self.playerView, viewController: self, companionSlots: nil)
        // Create an ad request with our ad tag, display container, and optional user context.
        let request = IMAAdsRequest(
            adTagUrl: DetailViewController.kTestAppAdTagUrl,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: contentPlayhead,
            userContext: nil)
        adsLoader.requestAds(with: request)
    }
    
    @objc func contentDidFinishPlaying(_ notification: Notification) {
        adsLoader.contentComplete()
    }
    @objc public func tail(string: String) -> String {
        return String(string.prefix(10))
    }
    func showContentPlayer() {
        let asset = PlayerResource(url: URL(string: str_url)!,cover: nil,subtitle: nil)
        playerView.setVideo(resource: asset)
    }
    
    func actionPlayer() {
        if(mWebView != nil){
            mWebView.evaluateJavaScript("javascript:turnOffMedia();") {(result, error) in
                print (error as Any)
            }
        }
        if(playerView.isPlaying){
            playerView.pause()
        }else{
            return
        }
    }
    // share
    func share() {
        let URLstring =  String(format:str_url)
        let urlToShare = URL(string:URLstring)
        let activityViewController = UIActivityViewController(
            activityItems: [urlToShare!],
            applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        //so that ipads won't crash
        present(activityViewController,animated: true,completion: nil)
    }
    func getDateTime() {
        let currentDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let convertedDate = dateFormatter.string(from: currentDate as Date)
        let date = tail(string: convertedDate)
        let hours = convertedDate[convertedDate.index(convertedDate.startIndex, offsetBy: 11)...]
        ReportClient.shared.teKReport?.date = date
        ReportClient.shared.teKReport?.dateHour = String(hours)
    }
}

extension Notification.Name {
    static let postNotifi = Notification.Name("postNotifi")
}

extension DetailViewController : WKUIDelegate{
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        if(message != ""){
            getDateTime()
            do {
                let data = message.data(using: String.Encoding.utf8)
                let model = try JSONDecoder().decode(DetailModel.self, from: data!)
                
                if(model.url_favorites != nil && model.url_favorites != ""){
                    let urlFV = self.mWebView.url!.absoluteString + model.url_favorites!
                    let url_favorites = URL(string: urlFV)
                    self.mTop.isHidden = true
                    self.playerView.pause()
                    self.playerView.isHidden = true
                    self.mWebView.load(URLRequest(url: url_favorites!))
                }else{
                    self.mTop.isHidden = false
                    if(model.urlwv_header != nil && model.urlwv_header != ""){
                        let urlheader = URL(string: model.urlwv_header!)
                        self.mTop.load(URLRequest(url: urlheader!))
                        if(model.height != 0){
                            heightCT.constant = CGFloat(model.height!)
                        }
                    }
                    let url = URL(string: model.urlwv!)
                    let playerUrl = model.url
                    if (playerUrl != nil && playerUrl != ""){
                        type = model.type
                        str_url = model.url;
                        self.playerView.pause()
                        showContentPlayer()
                        self.playerView.isHidden = false
                    }else{
                        //                        heightPlayer.constant = 0
                        playerView.layoutIfNeeded()
                        self.playerView.pause()
                        self.playerView.isHidden = true
                    }
                    if (url != nil){
                        self.mWebView.load(URLRequest(url: url!))
                    }
                }
            } catch {
                print(error)
            }
        }
        completionHandler()
    }
}

extension DetailViewController:WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case AppConst.JS_BACK_PRESS:
            onBackPress()
        case AppConst.JS_SAVE_DATA_FROM_WEB_REQUEST:
            saveDataFromWeb(message.body as? NSDictionary)
        case AppConst.JS_LOAD_DATA_FROM_APP_REQUEST:
            sendDataToWeb()
        case AppConst.JS_SHARE:
            share()
        default:
            print("some")
        }
    }
    
    func saveDataFromWeb(_ dic : NSDictionary?){
        let data  = dic?["data"] as? String ?? ""
        let defaults = UserDefaults.standard
        defaults.set(data, forKey: AppConst.DefaultsKeys.KEY_DATA_FROM_WEB)
    }
    
    func sendDataToWeb(){
        let defaults = UserDefaults.standard
        if let data = defaults.string(forKey: AppConst.DefaultsKeys.KEY_DATA_FROM_WEB){
            let js = "javascript:loadDataFromApp_return('\(data)');"
            mWebView.evaluateJavaScript(js) { (result, error) in
                print(error ?? "")
            }
        }
    }
}

// MARK: - IMAAdsManagerDelegate
extension DetailViewController: IMAAdsManagerDelegate {
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager!) {
        ReportClient.shared.teKReport?.adModeBegin = Int(Date().timeIntervalSince1970 * 1000)
        playerView.pause()
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager!) {
        ReportClient.shared.teKReport?.adModeComplete = Int(Date().timeIntervalSince1970 * 1000)
        playerView.play()
    }
    
    func adsManager(_ adsManager: IMAAdsManager!, didReceive event: IMAAdEvent!) {
        if event.type == IMAAdEventType.LOADED {
            adsManager.start()
        }
    }
    
    func adsManager(_ adsManager: IMAAdsManager!, didReceive error: IMAAdError!) {
        print("Error loading ads: " + error.message)
        showContentPlayer()
    }
}

// MARK: - IMAAdsLoaderDelegate
extension DetailViewController: IMAAdsLoaderDelegate {
    func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
        adsManager = adsLoadedData.adsManager
        adsManager.delegate = self
        adsManager.initialize(with: nil)
    }
    
    func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
        print("Error loading ads: " + adErrorData.adError.message)
        showContentPlayer()
    }
}

//    extension DetailViewController: GCKRequestDelegate {
//
//    }
//
//    extension DetailViewController: GCKSessionManagerListener {
//
//    }
//    extension DetailViewController: GCKUIMiniMediaControlsViewControllerDelegate {
//        func miniMediaControlsViewController(_ miniMediaControlsViewController: GCKUIMiniMediaControlsViewController, shouldAppear: Bool) {
//            updateControlBarsVisibility(shouldAppear: shouldAppear)
//        }
//    }

