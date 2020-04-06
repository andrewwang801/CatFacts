//
//  Utils.swift
//  CatFacts
//
//  Created by iOS Developer on 9/11/18.
//  Copyright © 2018 Pae. All rights reserved.
//

import UIKit

class Utils: NSObject {

    static func getStringSetting(key: String) -> String {
        let userDefaults = UserDefaults.standard
        let settingValue = userDefaults.string(forKey: key) ?? ""
        return settingValue
    }

    static func getIntSetting(key: String) -> Int {
        let userDefaults = UserDefaults.standard
        let settingValue = userDefaults.integer(forKey: key)
        return settingValue
    }

    static func getDoubleSetting(key: String) -> Double {
        let userDefaults = UserDefaults.standard
        let settingValue = userDefaults.double(forKey: key)
        return settingValue
    }

    static func getBoolSetting(key: String) -> Bool {
        let userDefaults = UserDefaults.standard
        let settingValue = userDefaults.bool(forKey: key)
        return settingValue
    }

    static func setStringSetting(key: String, value: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }

    static func setIntSetting(key: String, value: Int) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }

    static func setDoubleSetting(key: String, value: Double) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }

    static func setBoolSetting(key: String, value: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }

    static func getAppVersion() -> String {
        //First get the nsObject by defining as an optional anyObject
        let versionObject = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let version = versionObject as? String
        return version ?? ""
    }

    static func getInitials(name: String) -> String {
        let firstName = name.components(separatedBy: " ").first
        let lastName = name.components(separatedBy: " ").last
        let initials = "\(firstName?.first ?? "A")\(lastName?.first ?? "A")".uppercased()
        return initials
    }

    static func getRelativeDateTimeFor(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: date)

        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let timeString = dateFormatter.string(from: date)

        return dateString + " " + timeString
    }

}
