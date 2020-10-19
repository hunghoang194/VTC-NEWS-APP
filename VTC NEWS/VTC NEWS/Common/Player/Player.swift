//
//  Player.swift
//  Player
//
//  Created by Trung Hieu OS on 17/08/2020.
//  Copyright © 2020 Trung Hieu OS. All rights reserved.
//

import UIKit
import SnapKit
import MediaPlayer

/// PlayerDelegate to obserbe player state
public protocol PlayerDelegate : class {
    func Player(player: Player, playerStateDidChange state: PlayerState)
    func Player(player: Player, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval)
    func Player(player: Player, playTimeDidChange currentTime : TimeInterval, totalTime: TimeInterval)
    func Player(player: Player, playerIsPlaying playing: Bool)
    func Player(player: Player, playerOrientChanged isFullscreen: Bool)
}

/**
 internal enum to check the pan direction
 
 - horizontal: horizontal
 - vertical:   vertical
 */
enum PanDirection: Int {
    case horizontal = 0
    case vertical   = 1
}

open class Player: UIView {
    
    open weak var delegate: PlayerDelegate?
    open var playerControl: PlayerControlView?
    open var backBlock:((Bool) -> Void)?
    
    /// Gesture to change volume / brightness
    open var panGesture: UIPanGestureRecognizer!
    
    /// AVLayerVideoGravityType
    open var videoGravity = AVLayerVideoGravity.resizeAspect {
        didSet {
            self.playerLayer?.videoGravity = videoGravity
        }
    }
    
    open var isPlaying: Bool {
        get {
            return playerLayer?.isPlaying ?? false
        }
    }
    
    //Closure fired when play time changed
    open var playTimeDidChange:((TimeInterval, TimeInterval) -> Void)?

    //Closure fired when play state chaged
    @available(*, deprecated, message: "Use newer `isPlayingStateChanged`")
    open var playStateDidChange:((Bool) -> Void)?

    open var playOrientChanged:((Bool) -> Void)?

    open var isPlayingStateChanged:((Bool) -> Void)?


    open var playStateChanged:((PlayerState) -> Void)?
    
    open var avPlayer: AVPlayer? {
        return playerLayer?.player
    }
    
    open var playerLayer: PlayerLayerView?
    fileprivate var resource: PlayerResource!
    
    fileprivate var currentDefinition = 0
    
    fileprivate var controlView: PlayerControlView!
    
    fileprivate var customControlView: PlayerControlView?
    
    open var isFullScreen:Bool {
        get {
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }
    
    /// 滑动方向
    fileprivate var panDirection = PanDirection.horizontal
    
    /// 音量滑竿
    fileprivate var volumeViewSlider: UISlider!
    
    fileprivate let PlayerAnimationTimeInterval: Double             = 4.0
    fileprivate let PlayerControlBarAutoFadeOutTimeInterval: Double = 0.5
    
    /// 用来保存时间状态
    fileprivate var sumTime         : TimeInterval = 0
    fileprivate var totalDuration   : TimeInterval = 0
    fileprivate var currentPosition : TimeInterval = 0
    fileprivate var shouldSeekTo    : TimeInterval = 0
    
    fileprivate var isURLSet        = false
    fileprivate var isSliderSliding = false
    fileprivate var isPauseByUser   = false
    fileprivate var isVolume        = false
    fileprivate var isMaskShowing   = false
    fileprivate var isSlowed        = false
    fileprivate var isMirrored      = false
    fileprivate var isPlayToTheEnd  = false
    //视频画面比例
    fileprivate var aspectRatio: PlayerAspectRatio = .default
    
    //Cache is playing result to improve callback performance
    fileprivate var isPlayingCache: Bool? = nil
    
    // MARK: - Public functions
    
    /**
     Play
     
     - parameter resource:        media resource
     - parameter definitionIndex: starting definition index, default start with the first definition
     */
    open func setVideo(resource: PlayerResource, definitionIndex: Int = 0) {
        isURLSet = false
        self.resource = resource
        
        currentDefinition = definitionIndex
        controlView.prepareUI(for: resource, selectedIndex: definitionIndex)
        
        if PlayerConf.shouldAutoPlay {
            isURLSet = true
            let asset = resource.definitions[definitionIndex]
            playerLayer?.playAsset(asset: asset.avURLAsset)
        } else {
            controlView.showCover(url: resource.cover)
            controlView.hideLoader()
        }
    }
    
    /**
     auto start playing, call at viewWillAppear, See more at pause
     */
    open func autoPlay() {
        if !isPauseByUser && isURLSet && !isPlayToTheEnd {
            play()
        }
    }
    
    /**
     Play
     */
    open func play() {
        guard resource != nil else { return }
        
        if !isURLSet {
            let asset = resource.definitions[currentDefinition]
            playerLayer?.playAsset(asset: asset.avURLAsset)
            controlView.hideCoverImageView()
            isURLSet = true
        }
        
        panGesture.isEnabled = true
        playerLayer?.play()
        isPauseByUser = false
    }
    
    /**
     Pause
     
     - parameter allow: should allow to response `autoPlay` function
     */
    open func pause(allowAutoPlay allow: Bool = false) {
        playerLayer?.pause()
        isPauseByUser = !allow
    }
    
    /**
     seek
     
     - parameter to: target time
     */
    open func seek(_ to:TimeInterval, completion: (()->Void)? = nil) {
        playerLayer?.seek(to: to, completion: completion)
    }
    
    /**
     update UI to fullScreen
     */
    open func updateUI(_ isFullScreen: Bool) {
        controlView.updateUI(isFullScreen)
    }
    
    /**
     increade volume with step, default step 0.1
     
     - parameter step: step
     */
    open func addVolume(step: Float = 0.1) {
        self.volumeViewSlider.value += step
    }
    
    /**
     decreace volume with step, default step 0.1
     
     - parameter step: step
     */
    open func reduceVolume(step: Float = 0.1) {
        self.volumeViewSlider.value -= step
    }
    
    /**
     prepare to dealloc player, call at View or Controllers deinit funciton.
     */
    open func prepareToDealloc() {
        playerLayer?.prepareToDeinit()
        controlView.prepareToDealloc()
    }
    /**
     If you want to create Player with custom control in storyboard.
     create a subclass and override this method.
     
     - return: costom control which you want to use
     */
    open func storyBoardCustomControl() -> PlayerControlView? {
        return nil
    }
    
    
    // MARK: - Action Response
    
    @objc fileprivate func panDirection(_ pan: UIPanGestureRecognizer) {
        // 根据在view上Pan的位置，确定是调音量还是亮度
        let locationPoint = pan.location(in: self)
        
        // 我们要响应水平移动和垂直移动
        // 根据上次和本次移动的位置，算出一个速率的point
        let velocityPoint = pan.velocity(in: self)
        
        // 判断是垂直移动还是水平移动
        switch pan.state {
        case UIGestureRecognizer.State.began:
            // 使用绝对值来判断移动的方向
            let x = abs(velocityPoint.x)
            let y = abs(velocityPoint.y)
            
            if x > y {
                if PlayerConf.enablePlaytimeGestures {
                    self.panDirection = PanDirection.horizontal
                    
                    // 给sumTime初值
                    if let player = playerLayer?.player {
                        let time = player.currentTime()
                        self.sumTime = TimeInterval(time.value) / TimeInterval(time.timescale)
                    }
                }
            } else {
                self.panDirection = PanDirection.vertical
                if locationPoint.x > self.bounds.size.width / 2 {
                    self.isVolume = true
                } else {
                    self.isVolume = false
                }
            }
            
        case UIGestureRecognizer.State.changed:
            switch self.panDirection {
            case PanDirection.horizontal:
                self.horizontalMoved(velocityPoint.x)
            case PanDirection.vertical:
                self.verticalMoved(velocityPoint.y)
            }
            
        case UIGestureRecognizer.State.ended:
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
            case PanDirection.horizontal:
                controlView.hideSeekToView()
                isSliderSliding = false
                if isPlayToTheEnd {
                    isPlayToTheEnd = false
                    seek(self.sumTime, completion: {[weak self] in
                        self?.play()
                    })
                } else {
                    seek(self.sumTime, completion: {[weak self] in
                        self?.autoPlay()
                    })
                }
                // 把sumTime滞空，不然会越加越多
                self.sumTime = 0.0
                
            case PanDirection.vertical:
                self.isVolume = false
            }
        default:
            break
        }
    }
    
    fileprivate func verticalMoved(_ value: CGFloat) {
        if PlayerConf.enableVolumeGestures && self.isVolume{
            self.volumeViewSlider.value -= Float(value / 10000)
        }
        else if PlayerConf.enableBrightnessGestures && !self.isVolume{
            UIScreen.main.brightness -= value / 10000
        }
    }
    
    fileprivate func horizontalMoved(_ value: CGFloat) {
        guard PlayerConf.enablePlaytimeGestures else { return }
        
        isSliderSliding = true
        if let playerItem = playerLayer?.playerItem {
            // 每次滑动需要叠加时间，通过一定的比例，使滑动一直处于统一水平
            self.sumTime = self.sumTime + TimeInterval(value) / 100.0 * (TimeInterval(self.totalDuration)/400)
            
            let totalTime = playerItem.duration
            
            // 防止出现NAN
            if totalTime.timescale == 0 { return }
            
            let totalDuration = TimeInterval(totalTime.value) / TimeInterval(totalTime.timescale)
            if (self.sumTime >= totalDuration) { self.sumTime = totalDuration }
            if (self.sumTime <= 0) { self.sumTime = 0 }
            
            controlView.showSeekToView(to: sumTime, total: totalDuration, isAdd: value > 0)
        }
    }
    
    @objc open func onOrientationChanged() {
        self.updateUI(isFullScreen)
        delegate?.Player(player: self, playerOrientChanged: isFullScreen)
        playOrientChanged?(isFullScreen)
    }

    @objc fileprivate func fullScreenButtonPressed() {
        controlView.updateUI(!self.isFullScreen)
        if isFullScreen {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIApplication.shared.setStatusBarHidden(false, with: .fade)
            UIApplication.shared.statusBarOrientation = .portrait
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            UIApplication.shared.setStatusBarHidden(false, with: .fade)
            UIApplication.shared.statusBarOrientation = .landscapeRight
        }
    }
    
    // MARK: - 生命周期
    deinit {
        playerLayer?.pause()
        playerLayer?.prepareToDeinit()
        NotificationCenter.default.removeObserver(self, name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let customControlView = storyBoardCustomControl() {
            self.customControlView = customControlView
        }
        initUI()
        initUIData()
        configureVolume()
        preparePlayer()
    }
    
    @available(*, deprecated:3.0, message:"Use newer init(customControlView:_)")
    public convenience init(customControllView: PlayerControlView?) {
        self.init(customControlView: customControllView)
    }
    
    public init(customControlView: PlayerControlView?) {
        super.init(frame:CGRect.zero)
        self.customControlView = customControlView
        initUI()
        initUIData()
        configureVolume()
        preparePlayer()
    }
    
    public convenience init() {
        self.init(customControlView:nil)
    }
    
    // MARK: - 初始化
    fileprivate func initUI() {
        self.backgroundColor = UIColor.black
        
        if let customView = customControlView {
            controlView = customView
        } else {
            controlView = PlayerControlView()
        }
        
        addSubview(controlView)
        controlView.updateUI(isFullScreen)
        controlView.delegate = self
        controlView.player   = self
        controlView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panDirection(_:)))
        self.addGestureRecognizer(panGesture)
    }
    
    fileprivate func initUIData() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChanged), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    fileprivate func configureVolume() {
        let volumeView = MPVolumeView()
        for view in volumeView.subviews {
            if let slider = view as? UISlider {
                self.volumeViewSlider = slider
            }
        }
    }
    
    fileprivate func preparePlayer() {
        playerLayer = PlayerLayerView()
        playerLayer!.videoGravity = videoGravity
        insertSubview(playerLayer!, at: 0)
        playerLayer!.snp.makeConstraints { [weak self](make) in
          guard let `self` = self else { return }
          make.edges.equalTo(self)
        }
        playerLayer!.delegate = self
        controlView.showLoader()
        self.layoutIfNeeded()
    }
    // sua o day
    fileprivate func volumeAndMute() {
        playerLayer?.muteVolume()
    }
    // + 15s
    fileprivate func seekForward() {
        playerLayer?.forwardTime()
    }
    // - 15s
    fileprivate func seekBackward() {
        playerLayer?.seekBackward()
    }
    // cast
    open func cast() {
        playerLayer?.castScreen()
    }
//     share
    fileprivate func share() {
        playerLayer?.share()
    }
    open func hideControl() {
        controlView?.hideControlLive()
    }
    open func unHideControl() {
        controlView?.unHideControlLive()
    }
}

extension Player: PlayerLayerViewDelegate {
    public func Player(player: PlayerLayerView, playerIsPlaying playing: Bool) {
        controlView.playStateDidChange(isPlaying: playing)
        delegate?.Player(player: self, playerIsPlaying: playing)
        playStateDidChange?(player.isPlaying)
        isPlayingStateChanged?(player.isPlaying)
    }
    
    public func Player(player: PlayerLayerView, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
        PlayerManager.shared.log("loadedTimeDidChange - \(loadedDuration) - \(totalDuration)")
        controlView.loadedTimeDidChange(loadedDuration: loadedDuration, totalDuration: totalDuration)
        delegate?.Player(player: self, loadedTimeDidChange: loadedDuration, totalDuration: totalDuration)
        controlView.totalDuration = totalDuration
        self.totalDuration = totalDuration
    }
    
    public func Player(player: PlayerLayerView, playerStateDidChange state: PlayerState) {
        PlayerManager.shared.log("playerStateDidChange - \(state)")
        
        controlView.playerStateDidChange(state: state)
        switch state {
        case .readyToPlay:
            if !isPauseByUser {
                play()
            }
            if shouldSeekTo != 0 {
                seek(shouldSeekTo, completion: {[weak self] in
                  guard let `self` = self else { return }
                  if !self.isPauseByUser {
                      self.play()
                  } else {
                      self.pause()
                  }
                })
                shouldSeekTo = 0
            }
            
        case .bufferFinished:
            autoPlay()
            
        case .playedToTheEnd:
            isPlayToTheEnd = true
            
        default:
            break
        }
        panGesture.isEnabled = state != .playedToTheEnd
        delegate?.Player(player: self, playerStateDidChange: state)
        playStateChanged?(state)
    }
    
    public func Player(player: PlayerLayerView, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
        PlayerManager.shared.log("playTimeDidChange - \(currentTime) - \(totalTime)")
        delegate?.Player(player: self, playTimeDidChange: currentTime, totalTime: totalTime)
        // report
        ReportClient.shared.teKReport?.videoDuration = String(totalTime)
        if currentTime == 0.0{
            ReportClient.shared.teKReport?.playRequest = String(Date().timeIntervalSince1970 * 1000)
        }
        //
        self.currentPosition = currentTime
        totalDuration = totalTime
        if isSliderSliding {
            return
        }
        controlView.playTimeDidChange(currentTime: currentTime, totalTime: totalTime)
        controlView.totalDuration = totalDuration
        playTimeDidChange?(currentTime, totalTime)
    }
}

extension Player: PlayerControlViewDelegate {
    open func controlView(controlView: PlayerControlView,
                          didChooseDefinition index: Int) {
        shouldSeekTo = currentPosition
        playerLayer?.resetPlayer()
        currentDefinition = index
        playerLayer?.playAsset(asset: resource.definitions[index].avURLAsset)
    }
    
    open func controlView(controlView: PlayerControlView,
                          didPressButton button: UIButton) {
        if let action = PlayerControlView.ButtonType(rawValue: button.tag) {
            switch action {
            case .back:
                backBlock?(isFullScreen)
                if isFullScreen {
                    fullScreenButtonPressed()
                } else {
                    playerLayer?.prepareToDeinit()
                }
                
            case .play:
                if button.isSelected {
                    pause()
                } else {
                    if isPlayToTheEnd {
                        seek(0, completion: {[weak self] in
                          self?.play()
                        })
                        controlView.hidePlayToTheEndView()
                        isPlayToTheEnd = false
                    }
                    play()
                }
                
            case .replay:
                isPlayToTheEnd = false
                seek(0)
                play()
                
            case .fullscreen:
                fullScreenButtonPressed()
            
                // test button seek
            case .backVideo:
//                seekForward()
                print("back")
                
            case .nextVideo:
//                seekBackward()
                print("next")
                
//            case .mute:
//                volumeAndMute()
            case .cast:
                cast()
                
            case .share:
                share()
                
            default:
                print("[Error] unhandled Action")
            }
        }
    }
    
    open func controlView(controlView: PlayerControlView,
                          slider: UISlider,
                          onSliderEvent event: UIControl.Event) {
        switch event {
        case .touchDown:
            playerLayer?.onTimeSliderBegan()
            isSliderSliding = true
            
        case .touchUpInside :
            isSliderSliding = false
            let target = self.totalDuration * Double(slider.value)
            
            if isPlayToTheEnd {
                isPlayToTheEnd = false
                seek(target, completion: {[weak self] in
                  self?.play()
                })
                controlView.hidePlayToTheEndView()
            } else {
                seek(target, completion: {[weak self] in
                  self?.autoPlay()
                })
            }
        default:
            break
        }
    }
    
    open func controlView(controlView: PlayerControlView, didChangeVideoAspectRatio: PlayerAspectRatio) {
        self.playerLayer?.aspectRatio = self.aspectRatio
    }
    
    open func controlView(controlView: PlayerControlView, didChangeVideoPlaybackRate rate: Float) {
        self.playerLayer?.player?.rate = rate
    }
}
