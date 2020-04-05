import Foundation

struct GetStatusResponseBeaconId: Decodable {
    let beaconId: String

    let date: Date

    enum CodingKeys: String, CodingKey {
        case beaconId = "beacon_id"
        case date
    }
}

struct GetStatusResponse: Decodable {

    let status: DangerStatus

    let beaconIds: [GetStatusResponseBeaconId]

    enum CodingKeys: String, CodingKey {
        case status
        case beaconIds = "beacon_ids"
    }
}
