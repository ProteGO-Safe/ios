import XCTest

@testable import ProteGO

class ValidatorTests: XCTestCase {
    // MARK: - Subject under test
    var sut: Validator!
    // MARK: - Tests
    func testValidPhoneNumber() {
        // Given
        sut = Validator(type: .phoneNumber)
        let input = "+48123123123"
        // When
        let result = sut.isValid(text: input)
        // Then
        XCTAssertNoThrow(try result.get())
    }
    func testInalidPhoneNumber() {
        // Given
        sut = Validator(type: .phoneNumber)
        let input = "+48"
        // When
        let result = sut.isValid(text: input)
        // Then
        XCTAssertThrowsError(try result.get(), "") { error in
            XCTAssertEqual(error as? ValidationError, ValidationError.invalidPhoneNumber)
        }
    }

}
