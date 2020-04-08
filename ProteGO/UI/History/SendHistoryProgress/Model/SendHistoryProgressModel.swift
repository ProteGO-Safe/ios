import Foundation
import RxSwift
import RxCocoa

final class SendHistoryProgressModel: SendHistoryProgressModelType {

    private let gcpClient: GcpClientType

    private let encountersManager: EncountersManagerType

    init(gcpClient: GcpClientType, encountersManager: EncountersManagerType) {
        self.gcpClient = gcpClient
        self.encountersManager = encountersManager
    }

    func sendHistory() -> Single<Result<Void, Error>> {
        return self.gcpClient.sendHistory(encounters: Array(self.encountersManager.allEncounters))
            .map { $0.map { _ in return Void() } }
    }
}
