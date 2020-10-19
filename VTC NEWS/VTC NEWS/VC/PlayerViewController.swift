//
//  PlayerViewController.swift
//  VTC NEWS
//
//  Created by hưng hoàng on 10/7/20.
//  Copyright © 2020 hưng hoàng. All rights reserved.
//

import UIKit
import WebKit
import CoreMedia
import AVFoundation

class PlayerViewController: UIViewController {
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var pauseBt: UIButton!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var controlView: UIView!
    
    fileprivate var timer: Timer?

    
    let player = VTVCabPlayerSecure()
    var orientation : String?
    var playerUrl : String?
    var overlayUrl : String?
    let mweb = WKWebView()
    var isPlaying = true
    var isLoad = false
    var isLive : Bool?
    var type : Int? = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tapView))
        controlView.addGestureRecognizer(tapgesture)
        slider.minimumTrackTintColor = UIColor(red: 129, green: 0, blue: 66, alpha: 0.5)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !isLoad {
            
            isLoad = true
            let frame = playerView.bounds
            playVideoWithUrl(url: playerUrl!, frame: frame)
            addChild(player)
            playerView.addSubview(player.view)
            player.play()
            if(isLive != true){
                updateDuration()
            }else{
                self.duration.isHidden = true
                self.cancelButton.isHidden = false
                self.currentTime.isHidden = true
                self.slider.isHidden = true
                self.pauseBt.isHidden = true
            }
            
        }
    }
    
    func updateDuration(){
     
      let interval = CMTime(value: 1, timescale: 2)
        player.getPlayer()?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
                   let seconds = CMTimeGetSeconds(progressTime)
                   let secondsString = String(format: "%02d", Int(seconds.truncatingRemainder(dividingBy: 60)))
                   let minutesString = String(format: "%02d", Int(seconds / 60))
                   self.currentTime.text = "\(minutesString):\(secondsString)"
                   //lets move the slider thumb
          if let item = self.player.getPlayer()?.currentItem, item.status == .readyToPlay{
              if let duration =  self.player.getPlayer()?.currentItem?.duration {
                     let durationSeconds = CMTimeGetSeconds(duration)
                     self.slider.value = Float(seconds / durationSeconds)
                      let secondsString = String(format: "%02d", Int(durationSeconds.truncatingRemainder(dividingBy: 60)))
                      let minutesString = String(format: "%02d", Int(durationSeconds / 60))
                      self.duration.text = "\(minutesString):\(secondsString)"
                                      
                  }
          }
      })
    }
    
    func setUpWebview(){
        mweb.backgroundColor = UIColor.clear
        mweb.isOpaque = false
        mweb.translatesAutoresizingMaskIntoConstraints = false
        player.view.addSubview(mweb)
        constraintWebViewToBottom(mweb, marginTop: 0, marginRight: 0)
        let request = URLRequest(url: URL(string: overlayUrl!)!)
        mweb.load(request)
    }
    
    func constraintWebViewToBottom(_ view : UIView, marginTop : Int, marginRight : Int){
        if #available(iOS 11.0, *) {
            let guide = self.view.safeAreaLayoutGuide
            view.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant :CGFloat(marginRight) ).isActive = true
            view.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 0).isActive = true
            view.topAnchor.constraint(equalTo: guide.topAnchor, constant: CGFloat(marginTop)).isActive = true
        } else {
            NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self.player.view, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self.player.view, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self.player.view, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.player.view, attribute: .top, multiplier: 1.0, constant: CGFloat(marginTop)).isActive = true
        }
    }
    
    func playVideoWithUrl(url : String, frame : CGRect){
        let url = URL(string: url)
        let videoUrl = getActualURL(url: url!)
        if let orientation = orientation{
            if(orientation == "potrait"){
                 player.initPlayer(url: videoUrl, "", orientation: VTVCabPlayer.PORTRART, controller: self, frame: frame)
            }else{
                  player.initPlayer(url: videoUrl, "", orientation: VTVCabPlayer.LANDSCAPE, controller: self, frame: frame)
            }
        }else{
              player.initPlayer(url: videoUrl, "", orientation: VTVCabPlayer.LANDSCAPE, controller: self, frame: frame)
        }
       
        //        player.play()
    }
    
    open func getActualURL(url: URL) -> String {
        var actualURLComponents = URLComponents(url: url as URL, resolvingAgainstBaseURL: false)
        if url.scheme == "https" {
            actualURLComponents!.scheme = "sdk"
        }
        return url.absoluteString.replacingOccurrences(of: "https", with: "sdk")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension PlayerViewController{
    @IBAction func cancel(_ sender: Any) {
        player.releasePlayer()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pause(_ sender: Any) {
        if(isPlaying){
            let image = UIImage(named: "ic_play")
            pauseBt.setImage(image, for: .normal)
            player.getPlayer()?.pause()
        }else{
            let image = UIImage(named: "ic_pause")
            pauseBt.setImage(image, for: .normal)
            player.getPlayer()?.play()
        }
        
        isPlaying = !isPlaying
    }
    
    func actionPlayer() {
        if(isPlaying){
            isPlaying = !isPlaying
            let image = UIImage(named: "ic_play")
            pauseBt.setImage(image, for: .normal)
            player.getPlayer()?.pause()
        }else{
            return
        }
    }
    
    @IBAction func handleSlider(_ sender: Any) {
        if let duration = self.player.getPlayer()!.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            
            let value = Float64(slider.value) * totalSeconds
            
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            
            player.getPlayer()!.seek(to: seekTime)
        }
    }
    
    @objc fileprivate func tapView(){
        if timer != nil{
            return
        }
        if(isLive == true){
                    if self.cancelButton.isHidden {
                                  self.duration.isHidden = true
                                  self.cancelButton.isHidden = false
                                   self.currentTime.isHidden = true
                                   self.slider.isHidden = true
                                   self.pauseBt.isHidden = true
                              }else{
                                  timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (t) in
                                      self.timer?.invalidate()
                                      self.timer = nil
                                      self.duration.isHidden = true
                                      self.cancelButton.isHidden = true
                                      self.currentTime.isHidden = true
                                      self.slider.isHidden = true
                                      self.pauseBt.isHidden = true
                                  })
                              }
               }else{
                   if self.slider.isHidden {
                       self.duration.isHidden = false
                       self.cancelButton.isHidden = false
                       self.currentTime.isHidden = false
                       self.slider.isHidden = false
                       self.pauseBt.isHidden = false
                   }else{
                       timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (t) in
                           self.timer?.invalidate()
                           self.timer = nil
                           self.duration.isHidden = true
                           self.cancelButton.isHidden = true
                           self.currentTime.isHidden = true
                           self.slider.isHidden = true
                           self.pauseBt.isHidden = true
                       })
                   }
               }
//        if self.slider.isHidden {
//            self.duration.isHidden = false
//            self.currentTime.isHidden = false
//            self.slider.isHidden = false
//            self.pauseBt.isHidden = false
//        }else{
//            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (t) in
//                self.timer?.invalidate()
//                self.timer = nil
//                self.duration.isHidden = true
//                self.currentTime.isHidden = true
//                self.slider.isHidden = true
//                self.pauseBt.isHidden = true
//            })
//        }
    }
}

