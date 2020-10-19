
import UIKit
import AVKit
open class VTVCabPlayer: UIViewController {
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
        if(orientation == VTVCabPlayer.LANDSCAPE){
            mask = UIInterfaceOrientationMask.landscape
            orient = UIInterfaceOrientation.landscapeLeft
            currentOrient = VTVCabPlayer.LANDSCAPE
        }else{
            mask = UIInterfaceOrientationMask.portrait
            orient = UIInterfaceOrientation.portrait
            currentOrient = VTVCabPlayer.PORTRART
        }
    }
    func getOrient() -> Int {
        let preferences = UserDefaults.standard
        var orient : Int?
        let currentLevelKey = "Now_orientation"
        if preferences.object(forKey: currentLevelKey) == nil {
            orient  = VTVCabPlayer.LANDSCAPE
        } else {
            orient = preferences.integer(forKey: currentLevelKey)
        }
        return orient!
    }
    open func isLandscape()->Bool{
        return getOrient() == VTVCabPlayer.LANDSCAPE
    }
    func saveOrient(_ currentOrient : Int){
        let preference = UserDefaults.standard
        let orientKey = "Now_orientation"
        preference.set(currentOrient, forKey: orientKey)
        
    }
    
    
    open func setHeader(_ header : String){
        VTVCabResourceLoaderDelegate.shared.setHeader(header)
    }
    
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "currentItem.loadedTimeRanges"){
            indicatorView.stopAnimating()
        }
    }
    
    open func getPlayer() -> AVPlayer?{
        return streamingPlayerContainerView.player
    }
    open func initPlayer(url : String,_ token : String,orientation : Int, controller : UIViewController, frame : CGRect)  {
        self.streamUrl = url
        currentOrient = orientation
        saveOrient(currentOrient);
        playerItem = VTVCabResourceLoaderDelegate.shared.playerItem(with: streamUrl!)
        VTVCabResourceLoaderDelegate.shared.setHeader(token)
        VTVCabResourceLoaderDelegate.shared.error_delegate(delegate: self)
        self.player = AVPlayer(playerItem: playerItem)
        
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
        //            streamingPlayerContainerView = AVPlayerViewController()
        //            if(currentOrient == VTVCabPlayer.LANDSCAPE){
        //                if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
        //                     streamingPlayerContainerView = LandscapeLeftPlayer()
        //                } else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
        //                     streamingPlayerContainerView = LandscapeRightPlayer()
        //                }else if UIDevice.current.orientation == UIDeviceOrientation.portrait{
        //                    streamingPlayerContainerView = PortrartPlayer()
        //                }
        //
        //            }else{
        //                 streamingPlayerContainerView = PortrartPlayer()
        //            }
        //            print("IOS11-10")
        
        //        }
        self.playerFrame = frame
        streamingPlayerContainerView.player = player
        streamingPlayerContainerView.videoGravity = AVLayerVideoGravity.resizeAspect;
        streamingPlayerContainerView.view.frame = frame
        self.addChild(streamingPlayerContainerView)
        streamingPlayerContainerView.showsPlaybackControls = false
        self.view.addSubview(streamingPlayerContainerView.view)
        
    }
    
    open func updateVideoUrl(streamUrl : String, token : String){
        self.streamingPlayerContainerView.player?.pause()
        playerItem = VTVCabResourceLoaderDelegate.shared.playerItem(with: streamUrl)
        VTVCabResourceLoaderDelegate.shared.setHeader(token)
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
        self.player.pause()
        if let currentPlayerItem = self.playerItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: currentPlayerItem)
        }
        streamingPlayerContainerView.player = nil
        player = nil
        playerItem = nil
    }
}
extension VTVCabPlayer : VTVCabHelperDelegate{
    public func error() {
        VtvCabPlayerDelegate?.replay()
    }
    
}

extension Notification.Name {
    static let appEnterForground = Notification.Name(
        rawValue: "appEnterForground")
}
class LandscapeLeftPlayer: AVPlayerViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .landscapeLeft
    }
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        self.view.layoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
}
class LandscapeRightPlayer: AVPlayerViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .landscapeRight
    }
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        self.view.layoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
}
class PortrartPlayer: AVPlayerViewController {
    override  var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    override  var shouldAutorotate: Bool {
        return false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        self.view.layoutSubviews()
    }
}
extension AVPlayerViewController {
    func forceFullScreenMode() {
        let selectorName : String = {
            if #available(iOS 11, *) {
                return "_transitionToFullScreenAnimated:completionHandler:"
            } else {
                return "_transitionToFullScreenViewControllerAnimated:completionHandler:"
            }
        }()
        let selectorToForceFullScreenMode = NSSelectorFromString(selectorName)
        if self.responds(to: selectorToForceFullScreenMode) {
            self.perform(selectorToForceFullScreenMode, with: true, with: nil)
        }
    }
}
final class IOS11LandscapePlayer: AVPlayerViewController {
    override func viewDidLayoutSubviews() {
        UIViewController.attemptRotationToDeviceOrientation()
        DispatchQueue.main.async {
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
}
final class IOS11PotraitPlayer: AVPlayerViewController {
    override func viewDidLayoutSubviews() {
        UIViewController.attemptRotationToDeviceOrientation()
        DispatchQueue.main.async {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
    
}
