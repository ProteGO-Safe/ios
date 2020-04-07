import Foundation
import Quick
import Nimble
import RealmSwift
@testable import ProteGO

struct BeaconIdSpecsTester: Decodable {
    let beacon: BeaconId
}

//swiftlint:disable force_unwrapping
class BeaconIdSpecs: QuickSpec {
    override func spec() {
        describe("BeaconId") {
            context("Creating beacon id from correct string") {
                let testStructure = "{\"beacon\":\"0123456789ABCDEF0123456789ABCDEF\"}"
                let expectedBytes: [UInt8] = [0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF, 0x01, 0x23, 0x45, 0x67, 0x89,
                                              0xAB, 0xCD, 0xEF]
                var sut: BeaconId?

                beforeEach {
                    sut = (try? JSONDecoder().decode(BeaconIdSpecsTester.self,
                                                     from: testStructure.data(using: .utf8)!))?.beacon
                }

                it("should exist") {
                    expect(sut).toNot(beNil())
                }

                it("should return correct data") {
                    expect(sut?.getData()).to(equal(Data(expectedBytes)))
                }
            }
        }
    }
}
