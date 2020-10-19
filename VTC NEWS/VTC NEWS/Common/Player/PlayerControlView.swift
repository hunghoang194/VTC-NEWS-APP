//
//  PlayerControlView.swift
//  Player
//
//  Created by Trung Hieu OS on 17/08/2020.
//  Copyright © 2020 Trung Hieu OS. All rights reserved.
//

import UIKit
//import GoogleCast

@objc public protocol PlayerControlViewDelegate: class {
    /**
     call when control view choose a definition
     
     - parameter controlView: control view
     - parameter index:       index of definition
     */
    func controlView(controlView: PlayerControlView, didChooseDefinition index: Int)
    
    /**
     call when control view pressed an button
     
     - parameter controlView: control view
     - parameter button:      button type
     */
    func controlView(controlView: PlayerControlView, didPressButton button: UIButton)
    
    /**
     call when slider action trigged
     
     - parameter controlView: control view
     - parameter slider:      progress slider
     - parameter event:       action
     */
    func controlView(controlView: PlayerControlView, slider: UISlider, onSliderEvent event: UIControl.Event)
    
    /**
     call when needs to change playback rate
     
     - parameter controlView: control view
     - parameter rate:        playback rate
     */
    @objc optional func controlView(controlView: PlayerControlView, didChangeVideoPlaybackRate rate: Float)
}

open class PlayerControlView: UIView {
    
    open weak var delegate: PlayerControlViewDelegate?
    open weak var player: Player?
    
    // MARK: Variables
    open var resource: PlayerResource?
    open var status = UserDefaults.standard.bool(forKey: "isLive")
    open var selectedIndex     = 0
    open var isFullscreen      = false
    open var isMaskShowing     = true
    open var isMute: Bool      = false
    open var mutePlayer        = PlayerLayerView()
    
    open var totalDuration: TimeInterval = 0
    open var delayItem: DispatchWorkItem?
    
    var playerLastState: PlayerState = .notSetURL
    
    fileprivate var isSelectDefinitionViewOpened = false
    
    
    // MARK: UI Components - them phan tu o top or bottom
    /// main views which contains the topMaskView and bottom mask view
    open var mainMaskView      = UIView()
    open var topMaskView       = UIView()
    open var bottomMaskView    = UIView()
    open var centerMaskView    = UIView()
    /// Image view to show video cover
    open var maskImageView = UIImageView()
    /// top views
    open var topWrapperView    = UIView()
    open var chooseDefinitionView = UIView()
    // sua o day
    open var fullscreenButton  = UIButton(type: UIButton.ButtonType.custom)
    open var muteButton        = UIButton(type: UIButton.ButtonType.custom)
    open var shareLinkButton   = UIButton(type: UIButton.ButtonType.custom)
    open var shareScreenButton = UIButton(type: UIButton.ButtonType.custom)
    
    /// bottom view
    open var bottomWrapperView = UIView()
    open var currentTimeLabel  = UILabel()
    open var totalTimeLabel    = UILabel()
    
    // center view
    open var centerView        = UIView()
    open var leftLabel         = UILabel()
    open var rightLabel        = UILabel()
    open var backButton        = UIButton(type: UIButton.ButtonType.custom)
    open var nextButton        = UIButton(type: UIButton.ButtonType.custom)
    /// Progress slider
    open var timeSlider        = TimeSlider()
    
    /// load progress view
    open var progressView      = UIProgressView()
    
    /* play button
     playButton.isSelected = player.isPlaying
     */
    open var playButton = UIButton(type: UIButton.ButtonType.custom)
    
    /* fullScreen button
     fullScreenButton.isSelected = player.isFullscreen
     */
    
    open var subtitleLabel     = UILabel()
    open var subtitleBackView  = UIView()
    open var subtileAttribute: [NSAttributedString.Key : Any]?
    
    /// Activty Indector for loading
    //    open var loadingIndicator  = NVActivityIndicatorView(frame:  CGRect(x: 0, y: 0, width: 30, height: 30))
    let loadingIndicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
    }()
    
    open var seekToView       = UIView()
    open var seekToViewImage  = UIImageView()
    open var seekToLabel      = UILabel()
    open var replayButton     = UIButton(type: UIButton.ButtonType.custom)
    
    /// Gesture used to show / hide control view
    open var tapGesture: UITapGestureRecognizer!
    open var doubleTapGesture: UITapGestureRecognizer!
    
    // MARK: - handle player state change
    /**
     call on when play time changed, update duration here
     
     - parameter currentTime: current play time
     - parameter totalTime:   total duration
     */
    open func playTimeDidChange(currentTime: TimeInterval, totalTime: TimeInterval) {
        currentTimeLabel.text = Player.formatSecondsToString(currentTime)
        totalTimeLabel.text   = Player.formatSecondsToString(totalTime)
        timeSlider.value      = Float(currentTime) / Float(totalTime)
        showSubtile(from: resource?.subtitle, at: currentTime)
    }
    
    
    /**
     change subtitle resource
     
     - Parameter subtitles: new subtitle object
     */
    open func update(subtitles: PlayerSubtitles?) {
        resource?.subtitle = subtitles
    }
    
    /**
     call on load duration changed, update load progressView here
     
     - parameter loadedDuration: loaded duration
     - parameter totalDuration:  total duration
     */
    open func loadedTimeDidChange(loadedDuration: TimeInterval, totalDuration: TimeInterval) {
        progressView.setProgress(Float(loadedDuration)/Float(totalDuration), animated: true)
    }
    
    open func playerStateDidChange(state: PlayerState) {
        switch state {
        case .readyToPlay:
            hideLoader()
            
        case .buffering:
            showLoader()
            
        case .bufferFinished:
            hideLoader()
            
        case .playedToTheEnd:
            playButton.isSelected = false
            showPlayToTheEndView()
            controlViewAnimation(isShow: true)
            
        default:
            break
        }
        playerLastState = state
    }
    
    /**
     Call when User use the slide to seek function
     
     - parameter toSecound:     target time
     - parameter totalDuration: total duration of the video
     - parameter isAdd:         isAdd
     */
    open func showSeekToView(to toSecound: TimeInterval, total totalDuration:TimeInterval, isAdd: Bool) {
        seekToView.isHidden = false
        seekToLabel.text    = Player.formatSecondsToString(toSecound)
        
        let rotate = isAdd ? 0 : CGFloat(Double.pi)
        seekToViewImage.transform = CGAffineTransform(rotationAngle: rotate)
        
        let targetTime = Player.formatSecondsToString(toSecound)
        timeSlider.value = Float(toSecound / totalDuration)
        currentTimeLabel.text = targetTime
    }
    
    // MARK: - UI update related function
    /**
     Update UI details when player set with the resource
     
     - parameter resource: video resouce
     - parameter index:    defualt definition's index
     */
    open func prepareUI(for resource: PlayerResource, selectedIndex index: Int) {
        self.resource = resource
        self.selectedIndex = index
        //        titleLabel.text = resource.name
        prepareChooseDefinitionView()
        autoFadeOutControlViewWithAnimation()
    }
    
    open func playStateDidChange(isPlaying: Bool) {
        autoFadeOutControlViewWithAnimation()
        playButton.isSelected = isPlaying
    }
    
    /**
     auto fade out controll view with animtion
     */
    open func autoFadeOutControlViewWithAnimation() {
        cancelAutoFadeOutAnimation()
        delayItem = DispatchWorkItem { [weak self] in
            if self?.playerLastState != .playedToTheEnd {
                self?.controlViewAnimation(isShow: false)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + PlayerConf.animateDelayTimeInterval,
                                      execute: delayItem!)
    }
    
    /**
     cancel auto fade out controll view with animtion
     */
    open func cancelAutoFadeOutAnimation() {
        delayItem?.cancel()
    }
    
    /**
     Implement of the control view animation, override if need's custom animation
     
     - parameter isShow: is to show the controlview
     */
    open func controlViewAnimation(isShow: Bool) {
        let alpha: CGFloat = isShow ? 1.0 : 0.0
        self.isMaskShowing = isShow
        
        UIApplication.shared.setStatusBarHidden(!isShow, with: .fade)
        
        UIView.animate(withDuration: 0.3, animations: {[weak self] in
            guard let wSelf = self else { return }
            wSelf.topMaskView.alpha            = alpha
            wSelf.bottomMaskView.alpha         = alpha
            wSelf.centerMaskView.alpha         = alpha
            wSelf.mainMaskView.backgroundColor = UIColor(white: 0, alpha: isShow ? 0.4 : 0.0)
            
            if isShow {
                if wSelf.isFullscreen { wSelf.chooseDefinitionView.alpha = 1.0 }
            } else {
                wSelf.replayButton.isHidden = true
                wSelf.chooseDefinitionView.snp.updateConstraints { (make) in
                    make.height.equalTo(35)
                }
                wSelf.chooseDefinitionView.alpha = 0.0
            }
            wSelf.layoutIfNeeded()
        }) { [weak self](_) in
            if isShow {
                self?.autoFadeOutControlViewWithAnimation()
            }
        }
    }
    
    /**
     Implement of the UI update when screen orient changed
     
     - parameter isForFullScreen: is for full screen
     */
    open func updateUI(_ isForFullScreen: Bool) {
        isFullscreen = isForFullScreen
        fullscreenButton.isSelected = isForFullScreen
        chooseDefinitionView.isHidden = !PlayerConf.enableChooseDefinition || !isForFullScreen
        if isForFullScreen {
            if PlayerConf.topBarShowInCase.rawValue == 2 {
                topMaskView.isHidden = true
            } else {
                topMaskView.isHidden = false
            }
        } else {
            if PlayerConf.topBarShowInCase.rawValue >= 1 {
                topMaskView.isHidden = true
            } else {
                topMaskView.isHidden = false
            }
        }
    }
    
    /**
     Call when video play's to the end, override if you need custom UI or animation when played to the end
     */
    open func showPlayToTheEndView() {
        replayButton.isHidden = false
        playButton.isHidden = true
    }
    
    open func hidePlayToTheEndView() {
        replayButton.isHidden = true
        playButton.isHidden = false
    }
    
    open func showLoader() {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    open func hideLoader() {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
    }
    
    open func hideSeekToView() {
        seekToView.isHidden = true
    }
    
    open func showCoverWithLink(_ cover:String) {
        self.showCover(url: URL(string: cover))
    }
    
    open func showCover(url: URL?) {
        if let url = url {
            DispatchQueue.global(qos: .default).async { [weak self] in
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async(execute: { [weak self] in
                    guard let `self` = self else { return }
                    if let data = data {
                        self.maskImageView.image = UIImage(data: data)
                    } else {
                        self.maskImageView.image = nil
                    }
                    self.hideLoader()
                });
            }
        }
    }
    
    open func hideCoverImageView() {
        self.maskImageView.isHidden = true
    }
    
    open func prepareChooseDefinitionView() {
        guard let resource = resource else {
            return
        }
        for item in chooseDefinitionView.subviews {
            item.removeFromSuperview()
        }
        
        for i in 0..<resource.definitions.count {
            let button = PlayerClearityChooseButton()
            
            if i == 0 {
                button.tag = selectedIndex
            } else if i <= selectedIndex {
                button.tag = i - 1
            } else {
                button.tag = i
            }
            
            button.setTitle("\(resource.definitions[button.tag].definition)", for: UIControl.State())
            chooseDefinitionView.addSubview(button)
            button.addTarget(self, action: #selector(self.onDefinitionSelected(_:)), for: UIControl.Event.touchUpInside)
            button.snp.makeConstraints({ [weak self](make) in
                guard let `self` = self else { return }
                make.top.equalTo(chooseDefinitionView.snp.top).offset(35 * i)
                make.width.equalTo(50)
                make.height.equalTo(25)
                make.centerX.equalTo(chooseDefinitionView)
            })
            
            if resource.definitions.count == 1 {
                button.isEnabled = false
                button.isHidden = true
            }
        }
    }
    
    open func prepareToDealloc() {
        self.delayItem = nil
    }
    
    // MARK: - Action Response
    /**
     Call when some action button Pressed
     
     - parameter button: action Button
     */
    @objc open func onButtonPressed(_ button: UIButton) {
        autoFadeOutControlViewWithAnimation()
        if let type = ButtonType(rawValue: button.tag) {
            switch type {
            case .play, .replay:
                if playerLastState == .playedToTheEnd {
                    hidePlayToTheEndView()
                }
            default:
                break
            }
        }
        delegate?.controlView(controlView: self, didPressButton: button)
    }
    
    /**
     Call when the tap gesture tapped
     
     - parameter gesture: tap gesture
     */
    @objc open func onTapGestureTapped(_ gesture: UITapGestureRecognizer) {
        if playerLastState == .playedToTheEnd {
            return
        }
        controlViewAnimation(isShow: !isMaskShowing)
    }
    
    @objc open func onDoubleTapGestureRecognized(_ gesture: UITapGestureRecognizer) {
        guard let player = player else { return }
        guard playerLastState == .readyToPlay || playerLastState == .buffering || playerLastState == .bufferFinished else { return }
        
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }
    
    // MARK: - handle UI slider actions
    @objc func progressSliderTouchBegan(_ sender: UISlider)  {
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .touchDown)
    }
    
    @objc func progressSliderValueChanged(_ sender: UISlider)  {
        hidePlayToTheEndView()
        cancelAutoFadeOutAnimation()
        let currentTime = Double(sender.value) * totalDuration
        currentTimeLabel.text = Player.formatSecondsToString(currentTime)
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .valueChanged)
    }
    
    @objc func progressSliderTouchEnded(_ sender: UISlider)  {
        autoFadeOutControlViewWithAnimation()
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .touchUpInside)
    }
    
    
    // MARK: - private functions
    fileprivate func showSubtile(from subtitle: PlayerSubtitles?, at time: TimeInterval) {
        if let subtitle = subtitle, let group = subtitle.search(for: time) {
            subtitleBackView.isHidden = false
            subtitleLabel.attributedText = NSAttributedString(string: group.text,
                                                              attributes: subtileAttribute)
        } else {
            subtitleBackView.isHidden = true
        }
    }
    
    @objc fileprivate func onDefinitionSelected(_ button:UIButton) {
        let height = isSelectDefinitionViewOpened ? 35 : resource!.definitions.count * 40
        chooseDefinitionView.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        
        UIView.animate(withDuration: 0.3, animations: {[weak self] in
            self?.layoutIfNeeded()
        })
        isSelectDefinitionViewOpened = !isSelectDefinitionViewOpened
        if selectedIndex != button.tag {
            selectedIndex = button.tag
            delegate?.controlView(controlView: self, didChooseDefinition: button.tag)
        }
        prepareChooseDefinitionView()
    }
    
    @objc fileprivate func onReplyButtonPressed() {
        replayButton.isHidden = true
    }
    // hide live
    @objc open func hideControlLive() {
        totalTimeLabel.isHidden = true
        currentTimeLabel.isHidden = true
        leftLabel.isHidden = true
        progressView.backgroundColor = UIColor.red
        progressView.trackTintColor = UIColor.red
        progressView.tintColor = UIColor.red
        timeSlider.isHidden = true
        shareScreenButton.isSelected = false
        shareScreenButton.backgroundColor = UIColor.clear
    }
    @objc open func unHideControlLive() {
        totalTimeLabel.isHidden = false
        currentTimeLabel.isHidden = false
        leftLabel.isHidden = false
        progressView.backgroundColor = UIColor.white
        timeSlider.isHidden = false
        shareScreenButton.isHidden = false
    }
    
    // MARK: - Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUIComponents()
        addSnapKitConstraint()
        customizeUIComponents()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUIComponents()
        addSnapKitConstraint()
        customizeUIComponents()
    }
    
    /// Add Customize functions here
    open func customizeUIComponents() {
//        hideControlLive()
//        unHideControlLive()
    }
    // MARK: Custom button
    func setupUIComponents() {
        // Subtile view
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = UIColor.white
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.5
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        
        subtitleBackView.layer.cornerRadius = 2
        subtitleBackView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        subtitleBackView.addSubview(subtitleLabel)
        subtitleBackView.isHidden = true
        
        addSubview(subtitleBackView)
        
        // Main mask view
        addSubview(mainMaskView)
        mainMaskView.addSubview(topMaskView)
        mainMaskView.addSubview(bottomMaskView)
        mainMaskView.addSubview(centerMaskView)
        mainMaskView.insertSubview(maskImageView, at: 0)
        mainMaskView.clipsToBounds = true
        mainMaskView.backgroundColor = UIColor(white: 0, alpha: 0.4 )
        
        
        // Top views
        topMaskView.addSubview(topWrapperView)
        topWrapperView.addSubview(chooseDefinitionView)
        topWrapperView.addSubview(shareLinkButton)
        topWrapperView.addSubview(shareScreenButton)
        
        muteButton.tag = PlayerControlView.ButtonType.mute.rawValue
        isMute = !isMute
        if isMute {
            muteButton.setImage(ImageResourcePath("ic_volume"),  for: .normal)
            print("volume")
        } else {
            muteButton.setImage(ImageResourcePath("ic_mute"),  for: .normal)
            print("mute")
        }
        // share link
        shareLinkButton.tag = PlayerControlView.ButtonType.share.rawValue
        shareLinkButton.tintColor = UIColor.white
        shareLinkButton.setImage(ImageResourcePath("ic_share_gray"),    for: .normal)
        shareLinkButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        // cast
        shareScreenButton.tag = PlayerControlView.ButtonType.cast.rawValue
        shareScreenButton.tintColor = UIColor.white
        shareScreenButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        fullscreenButton.setImage(ImageResourcePath("icons8-chromecast-cast-button-32"),    for: .normal)
        
        chooseDefinitionView.clipsToBounds = true
        
        // Bottom views
        bottomMaskView.addSubview(bottomWrapperView)
        bottomWrapperView.addSubview(currentTimeLabel)
        bottomWrapperView.addSubview(totalTimeLabel)
        bottomWrapperView.addSubview(progressView)
        bottomWrapperView.addSubview(timeSlider)
        bottomWrapperView.addSubview(leftLabel)
        bottomWrapperView.addSubview(fullscreenButton)
        
        currentTimeLabel.textColor  = UIColor.white
        currentTimeLabel.font       = UIFont.systemFont(ofSize: 12)
        currentTimeLabel.text       = "00:00"
        currentTimeLabel.textAlignment = NSTextAlignment.center
        
        totalTimeLabel.textColor    = UIColor.white
        totalTimeLabel.font         = UIFont.systemFont(ofSize: 12)
        totalTimeLabel.text         = "00:00"
        totalTimeLabel.textAlignment   = NSTextAlignment.center
        
        leftLabel.textColor    = UIColor.white
        leftLabel.font         = UIFont.systemFont(ofSize: 10)
        leftLabel.text         = "/"
        leftLabel.textAlignment   = NSTextAlignment.center
        
        
        
        timeSlider.maximumValue = 1.0
        timeSlider.minimumValue = 0.0
        timeSlider.value        = 0.0
        timeSlider.setThumbImage(ImageResourcePath("Pod_Asset_Player_slider_thumb"), for: .normal)
        
        timeSlider.maximumTrackTintColor = UIColor.clear
        timeSlider.minimumTrackTintColor = PlayerConf.tintColor
        
        timeSlider.addTarget(self, action: #selector(progressSliderTouchBegan(_:)),
                             for: UIControl.Event.touchDown)
        
        timeSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)),
                             for: UIControl.Event.valueChanged)
        
        timeSlider.addTarget(self, action: #selector(progressSliderTouchEnded(_:)),
                             for: [UIControl.Event.touchUpInside,UIControl.Event.touchCancel, UIControl.Event.touchUpOutside])
        
        progressView.tintColor      = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6 )
        progressView.trackTintColor = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3 )
        
        fullscreenButton.tag = PlayerControlView.ButtonType.fullscreen.rawValue
        fullscreenButton.setImage(ImageResourcePath("Pod_Asset_Player_fullscreen"),    for: .normal)
        fullscreenButton.setImage(ImageResourcePath("Pod_Asset_Player_portialscreen"), for: .selected)
        fullscreenButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        mainMaskView.addSubview(loadingIndicator)
        
        //
        //        loadingIndicator.type  = PlayerConf.loaderType
        loadingIndicator.color = PlayerConf.tintColor
        // center view
        centerMaskView.addSubview(centerView)
        centerMaskView.addSubview(nextButton)
        //        centerMaskView.addSubview(leftLabel)
        //        centerMaskView.addSubview(rigthLabel)
        centerMaskView.addSubview(backButton)
        centerMaskView.addSubview(playButton)
        centerMaskView.addSubview(nextButton)
        
        // play
        playButton.tag = PlayerControlView.ButtonType.play.rawValue
        playButton.setImage(ImageResourcePath("Pod_Asset_Player_play"),  for: .normal)
        playButton.setImage(ImageResourcePath("Pod_Asset_Player_pause"), for: .selected)
        playButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        // back video
        backButton.tag = PlayerControlView.ButtonType.backVideo.rawValue
        backButton.setImage(ImageResourcePath("ic_back"),  for: .normal)
        backButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        // next video
        nextButton.tag = PlayerControlView.ButtonType.nextVideo.rawValue
        nextButton.setImage(ImageResourcePath("ic_next"),  for: .normal)
        nextButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        
        rightLabel.textColor    = UIColor.white
        rightLabel.font         = UIFont.systemFont(ofSize: 12)
        rightLabel.text         = "1"
        rightLabel.textAlignment   = NSTextAlignment.center
        
        // View to show when slide to seek
        addSubview(seekToView)
        seekToView.addSubview(seekToViewImage)
        seekToView.addSubview(seekToLabel)
        
        seekToLabel.font                = UIFont.systemFont(ofSize: 13)
        seekToLabel.textColor           = UIColor ( red: 0.9098, green: 0.9098, blue: 0.9098, alpha: 1.0 )
        seekToView.backgroundColor      = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7 )
        seekToView.layer.cornerRadius   = 4
        seekToView.layer.masksToBounds  = true
        seekToView.isHidden             = true
        
        seekToViewImage.image = ImageResourcePath("Pod_Asset_Player_seek_to_image")
        
        // center
        addSubview(replayButton)
        replayButton.isHidden = true
        replayButton.setImage(ImageResourcePath("Pod_Asset_Player_replay"), for: .normal)
        replayButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        replayButton.tag = ButtonType.replay.rawValue
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGestureTapped(_:)))
        addGestureRecognizer(tapGesture)
        
        if PlayerManager.shared.enablePlayControlGestures {
            doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDoubleTapGestureRecognized(_:)))
            doubleTapGesture.numberOfTapsRequired = 2
            addGestureRecognizer(doubleTapGesture)
            
            tapGesture.require(toFail: doubleTapGesture)
        }
    }
    
    func addSnapKitConstraint() {
        // Main mask view
        mainMaskView.snp.makeConstraints { [unowned self](make) in
            make.edges.equalTo(self)
        }
        
        maskImageView.snp.makeConstraints { [unowned self](make) in
            make.edges.equalTo(self.mainMaskView)
        }
        
        topMaskView.snp.makeConstraints { [unowned self](make) in
            make.top.left.right.equalTo(self.mainMaskView)
        }
        
        topWrapperView.snp.makeConstraints { [unowned self](make) in
            make.height.equalTo(50)
            if #available(iOS 11.0, *) {
                make.top.left.right.equalTo(self.topMaskView.safeAreaLayoutGuide)
                make.bottom.equalToSuperview()
            } else {
                make.top.equalToSuperview().offset(15)
                make.bottom.left.right.equalToSuperview()
            }
        }
        
        bottomMaskView.snp.makeConstraints { [unowned self](make) in
            make.bottom.left.right.equalTo(self.mainMaskView)
        }
        
        bottomWrapperView.snp.makeConstraints { [unowned self](make) in
            make.height.equalTo(70)
            if #available(iOS 11.0, *) {
                make.bottom.left.right.equalTo(self.bottomMaskView.safeAreaLayoutGuide)
                make.top.equalToSuperview()
            } else {
                make.edges.equalToSuperview()
            }
        }
        
        // Top views
        
        shareScreenButton.snp.makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.right.equalTo(self.shareLinkButton.snp.left).offset(10)
            make.centerY.equalTo(self.shareLinkButton)
        }
        
        shareLinkButton.snp.makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.right.equalToSuperview()
        }

        // Bottom views
        currentTimeLabel.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(30)
            make.left.equalTo(25)
            make.left.top.equalTo(self.bottomWrapperView).offset(20)
        }
        
        leftLabel.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self.currentTimeLabel.snp.right).offset(0)
            make.width.equalTo(5)
            make.height.equalTo(30)
            make.centerY.equalTo(self.currentTimeLabel)
        }
        totalTimeLabel.snp.makeConstraints { [unowned self](make) in
            make.centerY.equalTo(self.currentTimeLabel)
            make.left.equalTo(self.leftLabel.snp.right).offset(0)
            make.width.equalTo(40)
        }
        
        fullscreenButton.snp.makeConstraints { (make) in
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.right.equalTo(-15)
            make.centerY.equalTo(self.currentTimeLabel)
            make.right.top.equalTo(self.bottomWrapperView).offset(15)
        }
        
        
        progressView.snp.makeConstraints { (make) in
            make.height.equalTo(2)
            make.left.bottom.equalToSuperview().offset(15)
            make.right.bottom.equalToSuperview().offset(-15)
            make.centerY.left.right.equalTo(self.timeSlider)
            make.bottom.equalToSuperview().offset(-15)
            
        }

        timeSlider.snp.makeConstraints { [unowned self](make) in
            make.centerY.equalTo(self.progressView)
            make.left.equalTo(self.progressView.snp.left).offset(0).priority(750)
            make.height.equalTo(30)
        }
        
        loadingIndicator.snp.makeConstraints { [unowned self](make) in
            make.center.equalTo(self.mainMaskView)
        }
        
        // View to show when slide to seek
        seekToView.snp.makeConstraints { [unowned self](make) in
            make.center.equalTo(self.snp.center)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        
        seekToViewImage.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self.seekToView.snp.left).offset(15)
            make.centerY.equalTo(self.seekToView.snp.centerY)
            make.height.equalTo(15)
            make.width.equalTo(25)
        }
        
        seekToLabel.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self.seekToViewImage.snp.right).offset(10)
            make.centerY.equalTo(self.seekToView.snp.centerY)
        }
        
        replayButton.snp.makeConstraints { [unowned self](make) in
            make.center.equalTo(self.mainMaskView)
            make.width.height.equalTo(50)
        }
        
        subtitleBackView.snp.makeConstraints { [unowned self](make) in
            make.bottom.equalTo(self.snp.bottom).offset(-5)
            make.centerX.equalTo(self.snp.centerX)
            make.width.lessThanOrEqualTo(self.snp.width).offset(-10).priority(750)
        }
        
        subtitleLabel.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self.subtitleBackView.snp.left).offset(10)
            make.right.equalTo(self.subtitleBackView.snp.right).offset(-10)
            make.top.equalTo(self.subtitleBackView.snp.top).offset(2)
            make.bottom.equalTo(self.subtitleBackView.snp.bottom).offset(-2)
        }
        // centerView
        centerMaskView.snp.makeConstraints { [unowned self](make) in
            make.height.equalTo(50)
            make.left.right.equalTo(self.mainMaskView)
            make.centerY.equalTo(self.mainMaskView)
        }
        playButton.snp.makeConstraints { [unowned self](make) in
            make.centerY.equalTo(self.centerMaskView.snp.centerY)
            make.centerX.equalTo(self.centerMaskView.snp.centerX)
            make.width.height.equalTo(50)
        }
        
        backButton.snp.makeConstraints { [unowned self](make) in
            make.right.equalTo(self.playButton.snp.left).offset(-15)
            make.centerY.equalTo(self.playButton.snp.centerY)
            make.width.height.equalTo(50)
        }
        nextButton.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self.playButton.snp.right).offset(15)
            make.centerY.equalTo(self.playButton.snp.centerY)
            make.width.height.equalTo(50)
        }
    }
    
    fileprivate func ImageResourcePath(_ fileName: String) -> UIImage? {
        let bundle = Bundle(for: Player.self)
        return UIImage(named: fileName, in: bundle, compatibleWith: nil)
    }
}

