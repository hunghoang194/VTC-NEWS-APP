//
//  TimeSlider.swift
//  Player
//
//  Created by Trung Hieu OS on 17/08/2020.
//  Copyright © 2020 Trung Hieu OS. All rights reserved.
//

import UIKit

public class TimeSlider: UISlider {
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let trackHeight: CGFloat = 2
        let position = CGPoint(x: 0, y: 14)
        let customBounds = CGRect(origin: position, size: CGSize(width: bounds.size.width, height: trackHeight))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
    
    override open func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let rect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        let newx = rect.origin.x - 10
        let newRect = CGRect(x: newx, y: 0, width: 30, height: 30)
        return newRect
    }
}
