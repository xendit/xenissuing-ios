import Foundation
import Security
import XCTest
@testable import Xenissuing

struct TestEncryption: Codable, Hashable {
    let sessionKey: String
    let secret: String
    let iv: String
    let plain: String
}

final class SecureSessionTests: XCTestCase {
    var publicKeyData: Data!
    var privateKeyData: Data!
    var publicKeyTag = "com.tests.test_public_key"
    var privateKeyTag = "com.tests.test_private_key"
    var publicKey: SecKey!
    var privateKey: SecKey!

    override func setUp() {
        super.setUp()
        // Generate key pair
        privateKey = try! SecKey.createRandomKey(type: .rsa, bits: 2048, tag: privateKeyTag)
        publicKey = privateKey.publicKey()
        publicKeyData = try? publicKey.externalRepresentation()
    }

    override func tearDown() {
        SecKey.deleteKey(tag: publicKeyTag)
    }

    func testImportKey() {
        // Check that keys have been imported
        XCTAssertNotNil(publicKey, "Public key should not be nil")
        XCTAssertNotNil(privateKey, "Private key should not be nil")
    }

    func testGenerateSessionId() {
        let xcrypt = try! SecureSession(xenditPublicKeyData: publicKeyData)
        let sessionKey = try! xcrypt.generateRandom()
        let sessionId = try! xcrypt.generateSessionId(sessionKey: sessionKey)
        
        // Decrypt the sealed data
        let decryptedBytes = try! privateKey.decrypt(algorithm: .rsaEncryptionOAEPSHA256, ciphertext: sessionId.sealed)
        let decryptedData = Data(decryptedBytes)
        
        // Convert decrypted bytes back to string and compare with original base64 encoded session key
        let decryptedString = String(data: decryptedData, encoding: .utf8)!
        XCTAssertEqual(sessionKey.base64EncodedString(), decryptedString)
    }

    func testDecrypt() {
        let xcrypt = try! SecureSession(xenditPublicKeyData: publicKeyData)
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
    static func createRandomKey(type: KeyType, bits: Int, tag: String) throws -> SecKey? {
        var error: Unmanaged<CFError>?
        let keyO = SecKeyCreateRandomKey([
            kSecAttrKeyType: type.secAttrKeyTypeValue,
            kSecAttrKeySizeInBits: NSNumber(integerLiteral: bits),
            kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
        ] as CFDictionary, &error)
        // See here for apple's sample code for memory-managing returned errors
        // from the Security framework:
        // https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_as_data
        if let error = error?.takeRetainedValue() { throw error }
        return keyO
    }

    /// Gets the public key from a key pair.
    func publicKey() -> SecKey? {
        let publicKeyO = SecKeyCopyPublicKey(self)
        return publicKeyO
    }

    /// Exports a key.
    func externalRepresentation() throws -> Data? {
        var error: Unmanaged<CFError>?
        let dataO: CFData? = SecKeyCopyExternalRepresentation(self, &error)
        if let error = error?.takeRetainedValue() { throw error }
        return dataO as Data?
    }

    func decrypt(algorithm: SecKeyAlgorithm, ciphertext: Data) throws -> Data {
        var error: Unmanaged<CFError>?
        let plaintextO = SecKeyCreateDecryptedData(self, algorithm,
                                                   ciphertext as CFData, &error)
        if let error = error?.takeRetainedValue() { throw error }
        guard let plaintext = plaintextO else { throw TestsErrors.nilPlaintext }
        return plaintext as Data
    }

    static func addToKeychain(tag: String, key: Data) -> Bool {
        let attributes: [String: Any] = [
            String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
            String(kSecClass): kSecClassKey,
            String(kSecAttrApplicationTag): tag,
            String(kSecValueData): key,
            String(kSecReturnPersistentRef): true,
        ]
        let status = SecItemAdd(attributes as CFDictionary, nil)
        return status == 0
    }

    static func deleteKey(tag: String) {
        let keyToDelete = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
            kSecReturnRef as String: true,
        ] as CFDictionary

        let status = SecItemDelete(keyToDelete)
        if status != errSecSuccess {
            print("Error deleting key: \(status)")
        }
    }

    enum TestsErrors: Error {
        case nilKey
        case nilPublicKey
        case nilExternalRepresentation
        case nilCiphertext
        case nilPlaintext
    }
}
