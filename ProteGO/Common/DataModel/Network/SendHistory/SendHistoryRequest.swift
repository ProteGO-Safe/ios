import Foundation

struct SendHistoryEncounter: Encodable {
    let beaconId: String

    let encounterDate: Date

    let signalStrength: Int?
}

struct SendHistoryRequest: Encodable {

    let proof: String

    let encounters: [SendHistoryEncounter]

    let userId: String

    let platform: String

    let osVersion: String

    let deviceType: String

    let appVersion: String

    let apiVersion: String

    let lang: String

    init(confirmCode: String, encounters: [Encounter], userId: String,
         defaultParameters: DefaultRequestParameters = DefaultRequestParameters()) {
        self.encounters = encounters.compactMap({ encounter -> SendHistoryEncounter in
            return SendHistoryEncounter(beaconId: encounter.deviceId,
                                        encounterDate: encounter.date,
                                        signalStrength: encounter.signalStrength.value)
        })

        self.proof = confirmCode
        self.userId = userId
        self.platform = defaultParameters.platform
        self.osVersion = defaultParameters.osVersion
        self.deviceType = defaultParameters.deviceType
        self.appVersion = defaultParameters.appVersion
        self.apiVersion = defaultParameters.apiVersion
        self.lang = defaultParameters.lang
    }
}
