//
//  Report.swift
//  VTC NEWS
//
//  Created by hưng hoàng on 10/19/20.
//  Copyright © 2020 hưng hoàng. All rights reserved.
//

import Foundation
import SwiftyJSON

public final class TEKReport: NSCoding, Codable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let sourceType = "sourceType"
    static let bytesDelivered = "bytesDelivered"
    static let age = "age"
    static let destinationDomain = "destinationDomain"
    static let activeUser = "activeUser"
    static let referrerDomain = "referrerDomain"
    static let adModeBegin = "adModeBegin"
    static let dateHour = "dateHour"
    static let videoName = "videoName"
    static let video = "video"
    static let videoDuration = "videoDuration"
    static let videoSecondViewed = "videoSecondViewed"
    static let account = "account"
    static let playRequest = "playRequest"
    static let activeMedia = "activeMedia"
    static let city = "city"
    static let playRate = "playRate"
    static let engagementScore = "engagementScore"
    static let deviceType = "deviceType"
    static let deviceOs = "deviceOs"
    static let adModeComplete = "adModeComplete"
    static let date = "date"
    static let destinationPath = "destinationPath"
    static let dailyUniqueViewers = "dailyUniqueViewers"
    static let videoImpression = "videoImpression"
    static let videoView = "videoView"
    static let videoPercentViewed = "videoPercentViewed"
    static let country = "country"
  }

  // MARK: Properties
  public var sourceType: String?
  public var bytesDelivered: String?
  public var age: String?
  public var destinationDomain: String?
  public var activeUser: Int?
  public var referrerDomain: String?
  public var adModeBegin: Int?
  public var dateHour: String?
  public var videoName: String?
  public var video: String?
  public var videoDuration: String?
  public var videoSecondViewed: String?
  public var account: String?
  public var playRequest: String?
  public var activeMedia: Int?
  public var city: String?
  public var playRate: String?
  public var engagementScore: String?
  public var deviceType: String?
  public var deviceOs: String = "IOS"
  public var adModeComplete: Int?
  public var date: String?
  public var destinationPath: String?
  public var dailyUniqueViewers: Int?
  public var videoImpression: String?
  public var videoView: String?
  public var videoPercentViewed: String?
  public var country: String?

  // MARK: SwiftyJSON Initializers
  /// Initiates the instance based on the object.
  ///
  /// - parameter object: The object of either Dictionary or Array kind that was passed.
  /// - returns: An initialized instance of the class.
  public convenience init(object: Any) {
    self.init(json: JSON(object))
  }

  /// Initiates the instance based on the JSON that was passed.
  ///
  /// - parameter json: JSON object from SwiftyJSON.
  public required init(json: JSON) {
    sourceType = json[SerializationKeys.sourceType].string
    bytesDelivered = json[SerializationKeys.bytesDelivered].string
    age = json[SerializationKeys.age].string
    destinationDomain = json[SerializationKeys.destinationDomain].string
    activeUser = json[SerializationKeys.activeUser].int
    referrerDomain = json[SerializationKeys.referrerDomain].string
    adModeBegin = json[SerializationKeys.adModeBegin].int
    dateHour = json[SerializationKeys.dateHour].string
    videoName = json[SerializationKeys.videoName].string
    video = json[SerializationKeys.video].string
    videoDuration = json[SerializationKeys.videoDuration].string
    videoSecondViewed = json[SerializationKeys.videoSecondViewed].string
    account = json[SerializationKeys.account].string
    playRequest = json[SerializationKeys.playRequest].string
    activeMedia = json[SerializationKeys.activeMedia].int
    city = json[SerializationKeys.city].string
    playRate = json[SerializationKeys.playRate].string
    engagementScore = json[SerializationKeys.engagementScore].string
    deviceType = json[SerializationKeys.deviceType].string
    deviceOs = json[SerializationKeys.deviceOs].string ?? ""
    adModeComplete = json[SerializationKeys.adModeComplete].int
    date = json[SerializationKeys.date].string
    destinationPath = json[SerializationKeys.destinationPath].string
    dailyUniqueViewers = json[SerializationKeys.dailyUniqueViewers].int
    videoImpression = json[SerializationKeys.videoImpression].string
    videoView = json[SerializationKeys.videoView].string
    videoPercentViewed = json[SerializationKeys.videoPercentViewed].string
    country = json[SerializationKeys.country].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = sourceType { dictionary[SerializationKeys.sourceType] = value }
    if let value = bytesDelivered { dictionary[SerializationKeys.bytesDelivered] = value }
    if let value = age { dictionary[SerializationKeys.age] = value }
    if let value = destinationDomain { dictionary[SerializationKeys.destinationDomain] = value }
    if let value = activeUser { dictionary[SerializationKeys.activeUser] = value }
    if let value = referrerDomain { dictionary[SerializationKeys.referrerDomain] = value }
    if let value = adModeBegin { dictionary[SerializationKeys.adModeBegin] = value }
    if let value = dateHour { dictionary[SerializationKeys.dateHour] = value }
    if let value = videoName { dictionary[SerializationKeys.videoName] = value }
    if let value = video { dictionary[SerializationKeys.video] = value }
    if let value = videoDuration { dictionary[SerializationKeys.videoDuration] = value }
    if let value = videoSecondViewed { dictionary[SerializationKeys.videoSecondViewed] = value }
    if let value = account { dictionary[SerializationKeys.account] = value }
    if let value = playRequest { dictionary[SerializationKeys.playRequest] = value }
    if let value = activeMedia { dictionary[SerializationKeys.activeMedia] = value }
    if let value = city { dictionary[SerializationKeys.city] = value }
    if let value = playRate { dictionary[SerializationKeys.playRate] = value }
    if let value = engagementScore { dictionary[SerializationKeys.engagementScore] = value }
    if let value = deviceType { dictionary[SerializationKeys.deviceType] = value }
//    if let value = deviceOs { dictionary[SerializationKeys.deviceOs] = value }
    if let value = adModeComplete { dictionary[SerializationKeys.adModeComplete] = value }
    if let value = date { dictionary[SerializationKeys.date] = value }
    if let value = destinationPath { dictionary[SerializationKeys.destinationPath] = value }
    if let value = dailyUniqueViewers { dictionary[SerializationKeys.dailyUniqueViewers] = value }
    if let value = videoImpression { dictionary[SerializationKeys.videoImpression] = value }
    if let value = videoView { dictionary[SerializationKeys.videoView] = value }
    if let value = videoPercentViewed { dictionary[SerializationKeys.videoPercentViewed] = value }
    if let value = country { dictionary[SerializationKeys.country] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.sourceType = aDecoder.decodeObject(forKey: SerializationKeys.sourceType) as? String
    self.bytesDelivered = aDecoder.decodeObject(forKey: SerializationKeys.bytesDelivered) as? String
    self.age = aDecoder.decodeObject(forKey: SerializationKeys.age) as? String
    self.destinationDomain = aDecoder.decodeObject(forKey: SerializationKeys.destinationDomain) as? String
    self.activeUser = aDecoder.decodeObject(forKey: SerializationKeys.activeUser) as? Int
    self.referrerDomain = aDecoder.decodeObject(forKey: SerializationKeys.referrerDomain) as? String
    self.adModeBegin = aDecoder.decodeObject(forKey: SerializationKeys.adModeBegin) as? Int
    self.dateHour = aDecoder.decodeObject(forKey: SerializationKeys.dateHour) as? String
    self.videoName = aDecoder.decodeObject(forKey: SerializationKeys.videoName) as? String
    self.video = aDecoder.decodeObject(forKey: SerializationKeys.video) as? String
    self.videoDuration = aDecoder.decodeObject(forKey: SerializationKeys.videoDuration) as? String
    self.videoSecondViewed = aDecoder.decodeObject(forKey: SerializationKeys.videoSecondViewed) as? String
    self.account = aDecoder.decodeObject(forKey: SerializationKeys.account) as? String
    self.playRequest = aDecoder.decodeObject(forKey: SerializationKeys.playRequest) as? String
    self.activeMedia = aDecoder.decodeObject(forKey: SerializationKeys.activeMedia) as? Int
    self.city = aDecoder.decodeObject(forKey: SerializationKeys.city) as? String
    self.playRate = aDecoder.decodeObject(forKey: SerializationKeys.playRate) as? String
    self.engagementScore = aDecoder.decodeObject(forKey: SerializationKeys.engagementScore) as? String
    self.deviceType = aDecoder.decodeObject(forKey: SerializationKeys.deviceType) as? String
    self.deviceOs = aDecoder.decodeObject(forKey: SerializationKeys.deviceOs) as? String ?? ""
    self.adModeComplete = aDecoder.decodeObject(forKey: SerializationKeys.adModeComplete) as? Int
    self.date = aDecoder.decodeObject(forKey: SerializationKeys.date) as? String
    self.destinationPath = aDecoder.decodeObject(forKey: SerializationKeys.destinationPath) as? String
    self.dailyUniqueViewers = aDecoder.decodeObject(forKey: SerializationKeys.dailyUniqueViewers) as? Int
    self.videoImpression = aDecoder.decodeObject(forKey: SerializationKeys.videoImpression) as? String
    self.videoView = aDecoder.decodeObject(forKey: SerializationKeys.videoView) as? String
    self.videoPercentViewed = aDecoder.decodeObject(forKey: SerializationKeys.videoPercentViewed) as? String
    self.country = aDecoder.decodeObject(forKey: SerializationKeys.country) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(sourceType, forKey: SerializationKeys.sourceType)
    aCoder.encode(bytesDelivered, forKey: SerializationKeys.bytesDelivered)
    aCoder.encode(age, forKey: SerializationKeys.age)
    aCoder.encode(destinationDomain, forKey: SerializationKeys.destinationDomain)
    aCoder.encode(activeUser, forKey: SerializationKeys.activeUser)
    aCoder.encode(referrerDomain, forKey: SerializationKeys.referrerDomain)
    aCoder.encode(adModeBegin, forKey: SerializationKeys.adModeBegin)
    aCoder.encode(dateHour, forKey: SerializationKeys.dateHour)
    aCoder.encode(videoName, forKey: SerializationKeys.videoName)
    aCoder.encode(video, forKey: SerializationKeys.video)
    aCoder.encode(videoDuration, forKey: SerializationKeys.videoDuration)
    aCoder.encode(videoSecondViewed, forKey: SerializationKeys.videoSecondViewed)
    aCoder.encode(account, forKey: SerializationKeys.account)
    aCoder.encode(playRequest, forKey: SerializationKeys.playRequest)
    aCoder.encode(activeMedia, forKey: SerializationKeys.activeMedia)
    aCoder.encode(city, forKey: SerializationKeys.city)
    aCoder.encode(playRate, forKey: SerializationKeys.playRate)
    aCoder.encode(engagementScore, forKey: SerializationKeys.engagementScore)
    aCoder.encode(deviceType, forKey: SerializationKeys.deviceType)
    aCoder.encode(deviceOs, forKey: SerializationKeys.deviceOs)
    aCoder.encode(adModeComplete, forKey: SerializationKeys.adModeComplete)
    aCoder.encode(date, forKey: SerializationKeys.date)
    aCoder.encode(destinationPath, forKey: SerializationKeys.destinationPath)
    aCoder.encode(dailyUniqueViewers, forKey: SerializationKeys.dailyUniqueViewers)
    aCoder.encode(videoImpression, forKey: SerializationKeys.videoImpression)
    aCoder.encode(videoView, forKey: SerializationKeys.videoView)
    aCoder.encode(videoPercentViewed, forKey: SerializationKeys.videoPercentViewed)
    aCoder.encode(country, forKey: SerializationKeys.country)
  }

}

