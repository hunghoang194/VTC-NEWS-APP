
import UIKit
import AVKit
open class VTVCabPlayerSecure: UIViewController {
    var playerItem: AVPlayerItem!
    var VtvCabPlayerDelegate : VTVCabPlayerDelegate?
    var player: AVPlayer!
    var mask : UIInterfaceOrientationMask?
    var playerFrame : CGRect?
    var orient : UIInterfaceOrientation?
    private var streamUrl : String?
    private let queue = DispatchQueue(label: "com.anhtriu.queue")
    public static let  LANDSCAPE = 0
    public static let  PORTRART = 1
    var streamingPlayerContainerView : AVPlayerViewController!
    var currentOrient = 10
    
    let indicatorView : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
    }()
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    open func setDelegate(delegate : VTVCabPlayerDelegate){
        self.VtvCabPlayerDelegate = delegate;
    }
    
    open func play(){
        //        player.play()
        streamingPlayerContainerView.player?.play()
    }
    func setFullMode(){
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    func setEmbedMode(){
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    @objc func appWillEnterForegroundNotification() {
        if(streamingPlayerContainerView.view != nil && streamingPlayerContainerView.player != nil){
            streamingPlayerContainerView.player?.play()
            return
        }
        streamingPlayerContainerView.willMove(toParent: nil)
        streamingPlayerContainerView.view.removeFromSuperview()
        streamingPlayerContainerView.removeFromParent()
        currentOrient = getOrient()
        //        if #available(iOS 12, *){
        //            if(currentOrient == VTVCabPlayer.LANDSCAPE){
        //                streamingPlayerContainerView = IOS11LandscapePlayer()
        //            }else{
        //                streamingPlayerContainerView = IOS11PotraitPlayer()
        //            }
        //            print("IOS12")
        //        }else{
        streamingPlayerContainerView = AVPlayerViewController()
        if(currentOrient == VTVCabPlayerSecure.LANDSCAPE){
            let orientation = UIDevice.current.orientation
            if orientation == .landscapeLeft  {
                streamingPlayerContainerView = LandscapeLeftPlayer()
            }
            else if orientation == .landscapeRight{
                streamingPlayerContainerView = LandscapeRightPlayer()
            }
            else if orientation == .unknown{
                streamingPlayerContainerView = LandscapeRightPlayer()
            }else if orientation == .portrait || orientation == .portraitUpsideDown{
                streamingPlayerContainerView = LandscapeRightPlayer()
            }
        }
        else{
            streamingPlayerContainerView = PortrartPlayer()
        }
        print("IOS11-10")
        
        //        }
        streamingPlayerContainerView.player = player
        streamingPlayerContainerView.videoGravity = AVLayerVideoGravity.resizeAspect;
        if (UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight ){
            self.streamingPlayerContainerView.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
        }else if (UIDevice.current.orientation == UIDeviceOrientation.portrait){
            guard let frame = playerFrame  else {
                self.streamingPlayerContainerView.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
                return
            }
            self.streamingPlayerContainerView.view.frame = frame
        }
        self.addChild(streamingPlayerContainerView)
        streamingPlayerContainerView.showsPlaybackControls = false
        self.view.addSubview(streamingPlayerContainerView.view)
        streamingPlayerContainerView.player?.play()
    }
    override  open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    open func enableResumeFromBackground(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForegroundNotification),
                                               name: UIApplication.willEnterForegroundNotification, object:nil)
    }
    open func setOrientation(orientation : Int){
        if(orientation == VTVCabPlayerSecure.LANDSCAPE){
            mask = UIInterfaceOrientationMask.landscape
            orient = UIInterfaceOrientation.landscapeLeft
            currentOrient = VTVCabPlayerSecure.LANDSCAPE
        }else{
            mask = UIInterfaceOrientationMask.portrait
            orient = UIInterfaceOrientation.portrait
            currentOrient = VTVCabPlayerSecure.PORTRART
        }
    }
    func getOrient() -> Int {
        let preferences = UserDefaults.standard
        var orient : Int?
        let currentLevelKey = "Now_orientation"
        if preferences.object(forKey: currentLevelKey) == nil {
            orient  = VTVCabPlayerSecure.LANDSCAPE
        } else {
            orient = preferences.integer(forKey: currentLevelKey)
        }
        return orient!
    }
    open func isLandscape()->Bool{
        return getOrient() == VTVCabPlayerSecure.LANDSCAPE
    }
    func saveOrient(_ currentOrient : Int){
        let preference = UserDefaults.standard
        let orientKey = "Now_orientation"
        preference.set(currentOrient, forKey: orientKey)
        
    }
    
    
    open func setHeader(_ header : String){
        VTVCabResourceLoaderDelegateSecure.shared.setHeader(header)
    }
    
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "currentItem.loadedTimeRanges"){
            indicatorView.stopAnimating()
        }
    }
    
    open func getPlayer() -> AVPlayer?{
        if(streamingPlayerContainerView != nil){
            return streamingPlayerContainerView.player
        }
        return nil
    }
    
    open func initPlayerM3u8(url : String,_ token : String,orientation : Int, controller : UIViewController, frame : CGRect)  {
        self.streamUrl = url
        currentOrient = orientation
        saveOrient(currentOrient);
        playerItem = VTVCabResourceLoaderDelegateSecure.shared.playerItemM3u8(with: streamUrl!)
        VTVCabResourceLoaderDelegateSecure.shared.setHeader(token)
        VTVCabResourceLoaderDelegateSecure.shared.error_delegate(delegate: self)
        self.player = AVPlayer(playerItem: playerItem)
        //        let playerLayer = AVPlayerLayer(player: player)
        //        playerLayer.frame = self.view.bounds
        //        self.view.layer.addSublayer(playerLayer)
        //        if #available(iOS 12, *){
        //            if(currentOrient == VTVCabPlayer.LANDSCAPE){
        //                streamingPlayerContainerView = IOS11LandscapePlayer()
        //            }else{
        //                streamingPlayerContainerView = IOS11PotraitPlayer()
        //            }
        //            print("IOS12")
        //        }else{
        streamingPlayerContainerView = AVPlayerViewController()
        if(currentOrient == VTVCabPlayerSecure.LANDSCAPE){
            let orientation = UIDevice.current.orientation
            if orientation == .landscapeLeft  {
                streamingPlayerContainerView = LandscapeLeftPlayer()
            }
            else if orientation == .landscapeRight{
                streamingPlayerContainerView = LandscapeRightPlayer()
            }
            else if orientation == .unknown{
                streamingPlayerContainerView = LandscapeRightPlayer()
            }else if orientation == .portrait || orientation == .portraitUpsideDown{
                streamingPlayerContainerView = LandscapeRightPlayer()
            }
            
        }else{
            streamingPlayerContainerView = PortrartPlayer()
        }
        print("IOS11-10")
        
        //        }
        self.playerFrame = frame
        streamingPlayerContainerView.player = player
        streamingPlayerContainerView.videoGravity = AVLayerVideoGravity.resizeAspect
        streamingPlayerContainerView.view.frame = frame
        self.addChild(streamingPlayerContainerView)
        streamingPlayerContainerView.showsPlaybackControls = false
        self.view.addSubview(streamingPlayerContainerView.view)
        
    }
    
    open func initPlayer(url : String,_ token : String,orientation : Int, controller : UIViewController, frame : CGRect)  {
        self.streamUrl = url
        currentOrient = orientation
        saveOrient(currentOrient);
        playerItem = VTVCabResourceLoaderDelegateSecure.shared.playerItem(with: streamUrl!)
        VTVCabResourceLoaderDelegateSecure.shared.setHeader(token)
        VTVCabResourceLoaderDelegateSecure.shared.error_delegate(delegate: self)
        self.player = AVPlayer(playerItem: playerItem)
        //        let playerLayer = AVPlayerLayer(player: player)
        //        playerLayer.frame = self.view.bounds
        //        self.view.layer.addSublayer(playerLayer)
        //        if #available(iOS 12, *){
        //            if(currentOrient == VTVCabPlayer.LANDSCAPE){
        //                streamingPlayerContainerView = IOS11LandscapePlayer()
        //            }else{
        //                streamingPlayerContainerView = IOS11PotraitPlayer()
        //            }
        //            print("IOS12")
        //        }else{
        streamingPlayerContainerView = AVPlayerViewController()
        if(currentOrient == VTVCabPlayerSecure.LANDSCAPE){
            let orientation = UIDevice.current.orientation
            if orientation == .landscapeLeft  {
                streamingPlayerContainerView = LandscapeLeftPlayer()
            }
            else if orientation == .landscapeRight{
                streamingPlayerContainerView = LandscapeRightPlayer()
            }
            else if orientation == .unknown{
                streamingPlayerContainerView = LandscapeRightPlayer()
            }else if orientation == .portrait || orientation == .portraitUpsideDown{
                streamingPlayerContainerView = LandscapeRightPlayer()
            }
            
        }else{
            streamingPlayerContainerView = PortrartPlayer()
        }
        print("IOS11-10")
        
        //        }
        self.playerFrame = frame
        streamingPlayerContainerView.player = player
        streamingPlayerContainerView.videoGravity = AVLayerVideoGravity.resizeAspect
        streamingPlayerContainerView.view.frame = frame
        self.addChild(streamingPlayerContainerView)
        streamingPlayerContainerView.showsPlaybackControls = false
        self.view.addSubview(streamingPlayerContainerView.view)
        
    }
    
    open func updateVideoUrl(streamUrl : String, token : String){
        self.streamingPlayerContainerView.player?.pause()
        playerItem = VTVCabResourceLoaderDelegateSecure.shared.playerItem(with: streamUrl)
        VTVCabResourceLoaderDelegateSecure.shared.setHeader(token)
        self.streamingPlayerContainerView.player?.replaceCurrentItem(with: playerItem)
        self.streamingPlayerContainerView.player?.play()
    }
    
    open func enablePlaybackControls(enable : Bool){
        streamingPlayerContainerView.showsPlaybackControls =  enable
    }
    func forceFullMode(){
        streamingPlayerContainerView.forceFullScreenMode()
    }
    open func releasePlayer() {
        if self.player != nil{
            self.player.pause()
        }
        
        if let currentPlayerItem = self.playerItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: currentPlayerItem)
        }
        
        if streamingPlayerContainerView != nil{
            streamingPlayerContainerView.player = nil
        }
        
        player = nil
        playerItem = nil
    }
}
extension VTVCabPlayerSecure : VTVCabHelperDelegate{
    public func error() {
        VtvCabPlayerDelegate?.replay()
    }
    
}

