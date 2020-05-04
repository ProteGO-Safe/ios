//
//  BluetraceV2.swift
//  OpenTrace

/**
 File from https://github.com/opentrace-community/opentrace-ios/blob/master/OpenTrace/Bluetrace/Protocol/v2/BluetraceV2.swift

 Used in OpenTrace sources. Original implementation incorrectly assign batch tempIDs refresh time to UserDefaults ADVT_EXPIRY key instead of single tempID expiry date
 which results in wrong logic in V2Peripheral class.
*/

import Foundation

class BluetraceV2: BluetraceProtocol {

}

let bluetraceV2 = BluetraceV2(versionInt: 2, central: V2Central(), peripheral: V2Peripheral())

class V2Peripheral: PeripheralProtocol {

    func prepareReadRequestData(onComplete: @escaping (Data?) -> Void) {
        EncounterMessageManager.shared.getAdvtPayload { payload in
            onComplete(payload)
        }
    }

    func processWriteRequestDataReceived(dataWritten: Data) -> EncounterRecord? {
        do {
            let dataFromCentral = try JSONDecoder().decode(CentralWriteDataV2.self, from: dataWritten)
            let encounter = EncounterRecord(from: dataFromCentral)
            return encounter

        } catch {
            Logger.DLog("Error: \(error). characteristicValue is \(dataWritten)")
        }
        return nil
    }

}

class V2Central: CentralProtocol {
    func prepareWriteRequestData(tempId: String, rssi: Double, txPower: Double?) -> Data? {
        do {
            let dataToWrite = CentralWriteDataV2(
                mc: DeviceInfo.getModel(),
                rs: rssi,
                id: tempId,
                o: BluetraceConfig.OrgID,
                v: BluetraceConfig.ProtocolVersion)

            let encodedData = try JSONEncoder().encode(dataToWrite)

            return encodedData
        } catch {
            Logger.DLog("Error: \(error)")
        }

        return nil
    }

    func processReadRequestDataReceived(scannedPeriEncounter: EncounterRecord, characteristicValue: Data) -> EncounterRecord? {
        do {
            let peripheralCharData = try JSONDecoder().decode(PeripheralCharacteristicsDataV2.self, from: characteristicValue)
            var encounterStruct = scannedPeriEncounter

            encounterStruct.msg = peripheralCharData.id
            encounterStruct.update(modelP: peripheralCharData.mp)
            encounterStruct.org = peripheralCharData.o
            encounterStruct.v = peripheralCharData.v

            return encounterStruct

        } catch {
            Logger.DLog("Error: \(error). characteristicValue is \(characteristicValue)")
        }
        return nil
    }

}
