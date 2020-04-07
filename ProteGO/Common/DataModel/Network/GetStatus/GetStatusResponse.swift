import Foundation

struct GetStatusResponseBeaconId: Decodable {
    let beaconId: BeaconId

    let date: Date

    enum CodingKeys: String, CodingKey {
        case beaconId
        case date
    }
}

struct GetStatusResponse: Decodable {

    let status: DangerStatus

    let beaconIds: [GetStatusResponseBeaconId]

    enum CodingKeys: String, CodingKey {
        case status
        case beaconIds
    }
}
