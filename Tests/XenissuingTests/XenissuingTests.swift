import XCTest
@testable import Xenissuing

final class XenissuingTests: XCTestCase {
    let validPublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArY3DXFJ2M0EHbsD9r+2XgFVtpYEQR5bxnQZVHVxtVzQP8u2cv/1APs2cft+8E682wKGY7SFUEsFsoqxoak7qsfXYL/mOdvQe6XDyNC7N6oo9Zb8dUKtuy8qPb1bVeTbxAwDVUzIdJpiRVI69fAGCW7aF3jTAV7Q+Z5qUTaLUFyKvu3+j8u/A58Nw5fjOENTLHBZRrXhFtQC1eql2O6FiQRJBDACYtzhyFBMyT/B7SKNPkEvLm1w4AQEWxxwL93B8vxstfpatbJJvorJaDEl/glncxJVtZ0lBeB3dkWdro/TrhpPD7CHKlBIUKRfvq1TgmMFs9SP90DxD9l9mE+AUAwIDAQAB"

    func testValidPubicKey() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertNoThrow(try Xenissuing.createSecureSession(xenditPublicKeyData: Data(base64Encoded: validPublicKey)!))
    }

    func testCreateSecureSession() throws {
        let secureSession = try Xenissuing.createSecureSession(xenditPublicKeyData: Data(base64Encoded: validPublicKey)!)
        XCTAssertNotNil(secureSession.secureSession)
    }
}
