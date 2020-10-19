//
//  PlayerResource.swift
//  Player
//
//  Created by Trung Hieu OS on 17/08/2020.
//  Copyright © 2020 Trung Hieu OS. All rights reserved.
//


import Foundation
import AVFoundation

public class PlayerResource {
    public let cover: URL?
    public var subtitle: PlayerSubtitles?
    public let definitions: [PlayerResourceDefinition]

    public convenience init(url: URL, cover: URL? = nil, subtitle: URL? = nil) {
        ReportClient.shared.teKReport?.destinationDomain = url.host
        let fileArray = url.absoluteString.components(separatedBy: "/")
        let finalFileName = fileArray.last
        ReportClient.shared.teKReport?.videoName = finalFileName
        
        let definition = PlayerResourceDefinition(url: url, definition: "")
        
        var subtitles: PlayerSubtitles? = nil
        if let subtitle = subtitle {
            subtitles = PlayerSubtitles(url: subtitle)
        }
        self.init(definitions: [definition], cover: cover, subtitles: subtitles)
    }
    
    public init(definitions: [PlayerResourceDefinition], cover: URL? = nil, subtitles: PlayerSubtitles? = nil) {
        self.cover       = cover
        self.subtitle    = subtitles
        self.definitions = definitions
    }
}


open class PlayerResourceDefinition {
    public let url: URL
    public let definition: String
    
    /// An instance of NSDictionary that contains keys for specifying options for the initialization of the AVURLAsset. See AVURLAssetPreferPreciseDurationAndTimingKey and AVURLAssetReferenceRestrictionsKey above.
    public var options: [String : Any]?
    
    open var avURLAsset: AVURLAsset {
        get {
            return AVURLAsset(url: url)
        }
    }
    
    public init(url: URL, definition: String, options: [String : Any]? = nil) {
        self.url        = url
        self.definition = definition
        self.options    = options
    }
}
