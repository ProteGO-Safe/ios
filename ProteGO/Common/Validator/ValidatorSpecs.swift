import Foundation
import Quick
import Nimble
@testable import ProteGO

class ValidatorSpecs: QuickSpec {
    override func spec() {
        describe("ValidatorSpec") {
            var sut: Validator!
            context("valid phone number") {
                sut = Validator(type: .phoneNumber)
                let input = "+48123123123"
                let result = sut.validate(text: input)
                it("should no throw validation error") {
                    expect { try result.get() }.notTo(throwError())
                }
            }
            context("invalid phone number") {
                sut = Validator(type: .phoneNumber)
                let input = "+48"
                let result = sut.validate(text: input)
                it("should throw validation error") {
                    expect { try result.get() }.to(throwError(ValidationError.invalidPhoneNumber))
                }
            }
            context("phone number with invalid prefix") {
                sut = Validator(type: .phoneNumber)
                let input = "+49123456789"
                let result = sut.validate(text: input)
                it("should throw validation error") {
                    expect { try result.get() }.to(throwError(ValidationError.invalidPhoneNumber))
                }
            }
            context("too long phone number") {
                sut = Validator(type: .phoneNumber)
                let input = "+481234567898765"
                let result = sut.validate(text: input)
                it("should throw validation error") {
                    expect { try result.get() }.to(throwError(ValidationError.invalidPhoneNumber))
                }
            }
        }
    }
}
