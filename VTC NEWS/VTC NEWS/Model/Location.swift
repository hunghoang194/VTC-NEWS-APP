//
//  Location.swift
//  VTC NEWS
//
//  Created by hưng hoàng on 10/5/20.
//  Copyright © 2020 hưng hoàng. All rights reserved.
//
import Foundation
class Location : Encodable{
    var address : String?
    var latitude : Double?
    var longtitude : Double?
    init(address : String?, latitude : Double?, longtitude : Double?) {
        self.address = address
        self.latitude = latitude
        self.longtitude = longtitude
    }
}
