//
//  JSBridge+BridgeDataType.swift
//  safesafe
//
//  Created by Namedix on 17/02/2021.
//

import Foundation

extension JSBridge {
    enum BridgeDataType: Int {
        case dailyTopicUnsubscribe = 1
        case applicationLifecycle = 11
        case notificationsPermission = 35
        case serviceStatus = 51
        case setServices = 52
        case clearData = 37
        case uploadTemporaryExposureKeys = 43

        case exposureList = 61
        case appVersion = 62
        case systemLanguage = 63
        case clearExposureRisk = 66
        case requestAppReview = 68
        case route = 69

        case allDistricts = 70
        case districtsAPIFetch = 71
        case districtAction = 72
        case subscribedDistricts = 73

        case freeTestPinUpload = 80
        case freeTestSubscriptionInfo = 81
        case freeTestPinCodeFetch = 82

        case historicalData = 90
        case historicalDataRemove = 91

        case covidStatsSubscription = 100
        case setCovidStatsSubscription = 101
        case dashboardStats = 102
        case agregatedStats = 103
    }
}
