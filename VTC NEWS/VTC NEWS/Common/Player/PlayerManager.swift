//
//  PlayerManager.swift
//  Player
//
//  Created by Trung Hieu OS on 17/08/2020.
//  Copyright © 2020 Trung Hieu OS. All rights reserved.
//

import UIKit
import AVFoundation

public let PlayerConf = PlayerManager.shared

public enum PlayerTopBarShowCase: Int {
    case always         = 0
    case horizantalOnly = 1
    case none           = 2
}

open class PlayerManager {
    public static let shared = PlayerManager()
    
    /// tint color
    open var tintColor   = UIColor.white
    
    /// should auto play
    open var shouldAutoPlay = true
    
    open var topBarShowInCase = PlayerTopBarShowCase.always
    
    open var animateDelayTimeInterval = TimeInterval(5)
    
    /// should show log
    open var allowLog  = false
    
    /// use gestures to set brightness, volume and play position
    open var enableBrightnessGestures = true
    open var enableVolumeGestures = true
    open var enablePlaytimeGestures = true
    open var enableChooseDefinition = true
    open var enablePlayControlGestures = true
    
    func log(_ info:String) {
        if allowLog {
            print(info)
        }
    }
}
