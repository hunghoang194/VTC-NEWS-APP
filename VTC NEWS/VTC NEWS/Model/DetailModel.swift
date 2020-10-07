//
//  DetailModel.swift
//  VTC NEWS
//
//  Created by hưng hoàng on 10/5/20.
//  Copyright © 2020 hưng hoàng. All rights reserved.
//

import Foundation
class DetailModel: Codable{
    let url : String?
    let urlwv : String?
    let url_favorites: String?
    let urlwv_header : String?
    let height : Int?
    let isLive : Bool?
    let type : Int? = 0
    let url_image : String?
    let title: String?
    let description: String?

    private enum CodingKeys: String, CodingKey {
        case url = "url"
        case urlwv = "urlwv"
        case url_favorites="url_favorites"
        case urlwv_header="urlwv_header"
        case height = "height"
        case isLive = "isLive"
        case type = "type"
        case url_image = "url_image"
        case title = "title"
        case description = "description"
    }
}
class RadioModel: Codable{
    let url : String?
    let status : Int?
    private enum CodingKeys: String, CodingKey {
        case url = "url"
        case status = "status"
    }
}
