import CryptoSwift
import Foundation
import XCTest
@testable import Xenissuing

struct TestEncryption: Codable, Hashable {
    let sessionKey: String
    let secret: String
    let iv: String
    let plain: String
}

final class XenCryptTests: XCTestCase {
    // Valid RSA Public Key
    let validPublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArY3DXFJ2M0EHbsD9r+2XgFVtpYEQR5bxnQZVHVxtVzQP8u2cv/1APs2cft+8E682wKGY7SFUEsFsoqxoak7qsfXYL/mOdvQe6XDyNC7N6oo9Zb8dUKtuy8qPb1bVeTbxAwDVUzIdJpiRVI69fAGCW7aF3jTAV7Q+Z5qUTaLUFyKvu3+j8u/A58Nw5fjOENTLHBZRrXhFtQC1eql2O6FiQRJBDACYtzhyFBMyT/B7SKNPkEvLm1w4AQEWxxwL93B8vxstfpatbJJvorJaDEl/glncxJVtZ0lBeB3dkWdro/TrhpPD7CHKlBIUKRfvq1TgmMFs9SP90DxD9l9mE+AUAwIDAQAB"

    func testGenerateSessionId() {
        let privateKey = try! SecKey.createRandomKey(type: .rsa, bits: 2048)
        let publicKey = try! privateKey.publicKey()
        let publicKeyData = try! publicKey.externalRepresentation()
        let xcrypt = try! XenCrypt(xenditPublicKeyData: publicKeyData)
        let sessionKey = try! xcrypt.generateRandom()
        let sessionId = try! xcrypt.generateSessionId(sessionKey: sessionKey)
        let decryptedBytes = try! privateKey.decrypt(algorithm: .rsaEncryptionOAEPSHA256, ciphertext: sessionId.sealed)
        let decryptedData = Data(decryptedBytes)
        XCTAssertEqual(sessionKey.base64EncodedString(), decryptedData.base64EncodedString())
    }

    func testDecrypt() {
        let xcrypt = try! XenCrypt(xenditPublicKeyData: Data(base64Encoded: validPublicKey)!)
        for t in tests {
            let decrypted = try! xcrypt.decrypt(secret: t.secret, sessionKey: Data(base64Encoded: t.sessionKey)!, iv: t.iv)
            XCTAssertEqual(String(decoding: decrypted, as: UTF8.self), t.plain)
        }
    }
}

let tests: [TestEncryption] = [
    TestEncryption(
        sessionKey: "kojD5eHCyERG7JxABxx5IBr4Y0fUpe19",
        secret: "hTlNMg4CJZVdTIfXBehfxcU0XQ==",
        iv: "mxbZWKcnCkiRePK4lqibAQ==",
        plain: "372"
    ),
    TestEncryption(
        sessionKey: "ry+SUeQQ9ci6rzqBMaZMPgzbp0M6ruIrZXfIso4a6R8=",
        secret: "dmYJfv2Ou9fyz9WXe15DAeB9cg==",
        iv: "fbgKT6+XbpLWPizRNRF5sw==",
        plain: "372"
    ),
]

extension SecKey {
    enum KeyType {
        case rsa
        case ellipticCurve
        var secAttrKeyTypeValue: CFString {
            switch self {
            case .rsa:
                return kSecAttrKeyTypeRSA
            case .ellipticCurve:
                return kSecAttrKeyTypeECSECPrimeRandom
            }
        }
    }

    /// Creates a random key.
    static func createRandomKey(type: KeyType, bits: Int) throws -> SecKey {
        var error: Unmanaged<CFError>?
        let keyO = SecKeyCreateRandomKey([
            kSecAttrKeyType: type.secAttrKeyTypeValue,
            kSecAttrKeySizeInBits: NSNumber(integerLiteral: bits),
        ] as CFDictionary, &error)
        // See here for apple's sample code for memory-managing returned errors
        // from the Security framework:
        // https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_as_data
        if let error = error?.takeRetainedValue() { throw error }
        guard let key = keyO else { throw TestsErrors.nilKey }
        return key
    }

    /// Gets the public key from a key pair.
    func publicKey() throws -> SecKey {
        let publicKeyO = SecKeyCopyPublicKey(self)
        guard let publicKey = publicKeyO else { throw TestsErrors.nilPublicKey }
        return publicKey
    }

    /// Exports a key.
    /// RSA keys are returned in PKCS #1 / DER / ASN.1 format.
    /// EC keys are returned in ANSI X9.63 format.
    func externalRepresentation() throws -> Data {
        var error: Unmanaged<CFError>?
        let dataO = SecKeyCopyExternalRepresentation(self, &error)
        if let error = error?.takeRetainedValue() { throw error }
        guard let data = dataO else { throw TestsErrors.nilExternalRepresentation }
        return data as Data
    }

    func decrypt(algorithm: SecKeyAlgorithm, ciphertext: Data) throws -> Data {
        var error: Unmanaged<CFError>?
        let plaintextO = SecKeyCreateDecryptedData(self, algorithm,
                                                   ciphertext as CFData, &error)
        if let error = error?.takeRetainedValue() { throw error }
        guard let plaintext = plaintextO else { throw TestsErrors.nilPlaintext }
        return plaintext as Data
    }

    enum TestsErrors: Error {
        case nilKey
        case nilPublicKey
        case nilExternalRepresentation
        case nilCiphertext
        case nilPlaintext
    }
}
