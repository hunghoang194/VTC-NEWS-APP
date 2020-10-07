//
//  RadioViewController.swift
//  VTC NEWS
//
//  Created by hưng hoàng on 10/7/20.
//  Copyright © 2020 hưng hoàng. All rights reserved.
//

import UIKit
import WebKit
import CoreMedia
import AVFoundation

class RadioViewController: UIViewController {
    var player = VTVCabPlayerSecure()
    var webUrl : String!
    var str_url : String!
    
    @IBOutlet weak var playbackCT: PlaybackControl!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var mWebView: WKWebView!
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if(webUrl != nil && webUrl != ""){
            setUpWeb()
        }
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
    
    //MARK: - Method Support
    func actionPlayer() {
        if(playbackCT.isPlaying){
            playbackCT.isPlaying = !playbackCT.isPlaying
            let image = UIImage(named: "ic_play")
            playbackCT.pauseBt.setImage(image, for: .normal)
            player.getPlayer()?.pause()
        }else{
            return
        }
    }
    
    func setUpWeb(){
        if let url = URL(string: webUrl ?? "") {
            let request = URLRequest(url: url)
            mWebView.uiDelegate = self
            mWebView.load(request)
            mWebView.scrollView.showsHorizontalScrollIndicator = false
            mWebView.scrollView.showsVerticalScrollIndicator = false
        }
    }
    
    func setUpPlayer(){
        playerView.addSubview(player.view)
        playvideo()
    }
    
    func playvideo(){
        playVideoWithUrl(url: str_url, frame: playerView.bounds)
        let interval = CMTime(value: 1, timescale: 2)
        player.getPlayer()?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
            if let item = self.player.getPlayer()?.currentItem, item.status == .readyToPlay{
                // call lai ham wwebview
                let js = "javascript:getStatusPlayer_return('ready');"
                print(js)
                self.mWebView.evaluateJavaScript(js) { (result,
                    error) in
                    print(error)
                }
            }
        })
    }
    
    func playVideoWithUrl(url : String, frame : CGRect){
        let urlen = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let urlVideo = URL(string: urlen!)
        let videoUrl = getActualURL(url: urlVideo!)
        player.initPlayerM3u8(url: videoUrl, "", orientation: VTVCabPlayerSecure.PORTRART, controller: self, frame: frame)
        player.play()
    }
    
    func onBackPress(){
        player.releasePlayer()
        self.dismiss(animated: true, completion: nil)
    }
    
    open func getActualURL(url: URL) -> String {
        var actualURLComponents = URLComponents(url: url as URL, resolvingAgainstBaseURL: false)
        if url.scheme == "https" {
            actualURLComponents!.scheme = "sdk"
        }
        return url.absoluteString.replacingOccurrences(of: "https", with: "sdk")
    }
}

extension RadioViewController : WKUIDelegate{
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        if(message != ""){
            do {
                if let dic = try JSONSerialization.jsonObject(with: message.data(using: .utf8)!, options: []) as? [String: Any]{
                    let status = dic["status"] as? Int ?? 0
                    let url = dic["url"] as? String ?? ""
                    
                    switch status {
                    case 1:
                        // play
                        str_url = url
                        playvideo()
                        break
                    case 2:
                        player.getPlayer()?.pause()
                        break
                    case 3:
                        player.getPlayer()?.play()
                        break
                        
                    default:
                        break
                    }
                }
            } catch {
                print(error)
            }
        }
        completionHandler()
    }
}

