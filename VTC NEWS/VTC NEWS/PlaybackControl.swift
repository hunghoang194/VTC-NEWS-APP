//
//  PlaybackControl.swift
//  VTC NEWS
//
//  Created by hưng hoàng on 10/7/20.
//  Copyright © 2020 hưng hoàng. All rights reserved.
//

import UIKit
import AVKit
protocol ControlDelegate :class {
    func pause()
    func play()
    func seek()
    func showFull()
    func next()
    func back()
    func share()
    func cast()
    func forward()
    func backWard()
}
class PlaybackControl: UIView {
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var zoomBt: UIButton!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var pauseBt: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    var isLive : Bool?
    fileprivate var timer: Timer?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    weak var delegate : ControlDelegate?

    let kCONTENT_XIB_NAME = "PlaybackControl"
    
    var isPlaying = true
    @IBAction func pause(_ sender: Any) {
        if(isPlaying){
            let image = UIImage(named: "ic_play")
            pauseBt.setImage(image, for: .normal)
            delegate!.pause()
        }else{
            let image = UIImage(named: "ic_pause")
            pauseBt.setImage(image, for: .normal)
            delegate!.play()
        }
        
        isPlaying = !isPlaying
    }
    @IBAction func nextPress(_ sender: Any) {
    }
    @IBAction func backPress(_ sender: Any) {
    }
    @IBAction func backWard(_ sender: Any) {
    }
    @IBAction func forwardPress(_ sender: Any) {
    }
    @IBAction func sharePress(_ sender: Any) {
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    func getSlider() -> UISlider{
        return slider
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    @IBAction func showFull(_ sender: Any) {
        delegate?.showFull()
    }
    
    @IBAction func handleSlider(_ sender: Any) {
        delegate?.seek()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tapView))
        self.addGestureRecognizer(tapgesture)
    }
    
    @objc fileprivate func tapView(){
        if timer != nil{
            return
        }
        if(isLive == true){
             if self.zoomBt.isHidden {
                           self.duration.isHidden = true
                           self.zoomBt.isHidden = false
                            self.currentTime.isHidden = true
                            self.slider.isHidden = true
                            self.pauseBt.isHidden = true
                       }else{
                           timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (t) in
                               self.timer?.invalidate()
                               self.timer = nil
                               self.duration.isHidden = true
                               self.zoomBt.isHidden = true
                               self.currentTime.isHidden = true
                               self.slider.isHidden = true
                               self.pauseBt.isHidden = true
                           })
                       }
        }else{
            if self.slider.isHidden {
                self.duration.isHidden = false
                self.zoomBt.isHidden = false
                self.currentTime.isHidden = false
                self.slider.isHidden = false
                self.pauseBt.isHidden = false
            }else{
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (t) in
                    self.timer?.invalidate()
                    self.timer = nil
                    self.duration.isHidden = true
                    self.zoomBt.isHidden = true
                    self.currentTime.isHidden = true
                    self.slider.isHidden = true
                    self.pauseBt.isHidden = true
                })
            }
        }
        
    }
    
}
extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}

