import Foundation

struct SendHistoryEncounter: Encodable {
    let beaconId: String

    let encounterDate: Date

    let signalStrength: Int?

    enum CodingKeys: String, CodingKey {
        case beaconId
        case encounterDate
        case signalStrength
    }
}

struct SendHistoryRequest: Encodable {

    let encounters: [SendHistoryEncounter]

    let userId: String

    let platform: String

    let osVersion: String

    let deviceType: String

    let appVersion: String

    let apiVersion: String

    let lang: String

    enum CodingKeys: String, CodingKey {
        case encounters
        case userId
        case platform
        case osVersion
        case deviceType
        case appVersion
        case apiVersion
        case lang
    }

    init(encounters: [Encounter], userId: String, defaultParameters: DefaultRequestParameters = DefaultRequestParameters()) {
        self.encounters = encounters.compactMap({ encounter -> SendHistoryEncounter in
            return SendHistoryEncounter(beaconId: encounter.deviceId,
                                        encounterDate: encounter.date,
                                        signalStrength: encounter.signalStrength.value)
        })
        self.userId = userId
        self.platform = defaultParameters.platform
        self.osVersion = defaultParameters.osVersion
        self.deviceType = defaultParameters.deviceType
        self.appVersion = defaultParameters.appVersion
        self.apiVersion = defaultParameters.apiVersion
        self.lang = defaultParameters.lang
    }
}
