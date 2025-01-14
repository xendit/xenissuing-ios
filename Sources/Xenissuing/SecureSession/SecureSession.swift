import Crypto
import CryptoKit
import CryptoSwift
import Foundation
import Security

protocol Crypto {
    func generateRandom(size: Int) throws -> Data
    func generateSessionId(sessionKey: Data) throws -> SecuredSession
    func encrypt(plain: Data, iv: Data, sessionKey: Data) throws -> SecuredSession
    func decrypt(secret: String, sessionKey: Data, iv: String) throws -> Data
}

/// Encapsulates encrypted message and key used as encryption key.
public struct SecuredSession {
    internal let key: Data
    public let sealed: Data
    public init(key: Data, sealed: Data) {
        self.key = key
        self.sealed = sealed
    }
}

// MARK: - SecureSession

@available(macOS 10.15, *)
public class SecureSession: Crypto {
    /// The key provided by Xendit.
    let xenditPublicKey: SecKey
    var secureSession: SecuredSession?

    /**
     Initializes an object with the provided public key data and tag.

     - Parameters:
     - xenditPublicKeyData: The public key data.
     - xenditPublicKeyTag: The keychain tag for the public key. Defaults to nil.

     - Throws:
     - XenError.convertKeyDataError: If the public key data cannot be converted to a key.
     - XenError.updateKeychainError: If the keychain cannot be updated with the new key data.
     - XenError.addKeychainError: If the the new key cannot be added to the keychain.

     - Note:
     - The error message passed is optional, if no message is passed the default message from the XenError enumeration will be used
     - SeeAlso:
     - SecureSession: Class used to create and update the keychain
     - XenError: Enumeration that defines the possible errors that can be thrown by the function
     */
    init(xenditPublicKeyData: Data, xenditPublicKeyTag: String? = nil) throws {
        if let publicTag = xenditPublicKeyTag {
            if let keyFromKeychain = SecureSession.getKeyFromKeychainAsData(tag: publicTag) {
                if keyFromKeychain != xenditPublicKeyData {
                    if !SecureSession.updateKeychain(tag: publicTag, key: xenditPublicKeyData) {
                        throw XenError.updateKeychainError("")
                    }
                }
                self.xenditPublicKey = SecureSession.getKeyFromKeychain(tag: publicTag)!
            } else if let key = SecureSession.createKeyFromData(key: xenditPublicKeyData) {
                if !SecureSession.addToKeychain(tag: publicTag, key: xenditPublicKeyData) {
                    throw XenError.addKeychainError("")
                }
                self.xenditPublicKey = key
            } else {
                throw XenError.convertKeyDataError("")
            }
        } else {
            if let key = SecureSession.createKeyFromData(key: xenditPublicKeyData) {
                self.xenditPublicKey = key
            } else {
                throw XenError.convertKeyDataError("")
            }
        }
        let sKey = try self.generateRandom()
        self.secureSession = try self.generateSessionId(sessionKey: sKey)
    }
    
    /**
     Returns the encrypted session key.
     */
    public func getSessionId() -> Data {
        // This should be used for API authentication
        return self.secureSession!.sealed
    }

    public func getSessionKey() -> Data {
        // This should be used for validation
        return self.secureSession!.key
    }

    // deprecate ambiguous method
    @available(*, deprecated, message: "Use getSessionId() instead")
    public func getEncryptedKey() -> Data {
        return getSessionId()
    }

    // deprecate ambiguous method
    @available(*, deprecated, message: "Use getSessionKey() instead")
    public func getKey() -> Data {
        return getSessionKey()
    }

    public func decryptCardData(secret: String, iv: String) throws -> Data {
        return try self.decrypt(secret: secret, sessionKey: self.getSessionKey(), iv: iv)
    }

    /**
     Generates a random 32 bytes keys.
      - Throws: `XenError.generateRandomKeyError`
                if  there was any issue when trying to generate the symmetric key.
      - Returns: the random session key.
      */
    internal func generateRandom(size _: Int = 32) throws -> Data {
        var randomBytes = [UInt8](repeating: 0, count: 32)
        let result = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        guard result == errSecSuccess else {
            throw XenError.generateRandomKeyError("")
        }
        return Data(randomBytes)
    }

    /**
     Generates Session Id following AES-CBC  scheme using the key provided by Xendit.
     IV used is 16 bytes size.
      - Parameter sessionKey: Random key `Data`.
      - Throws: `XenError.encryptionError`
                if  there was any issue during encryption.
      - Returns: The encrypted text
      */
    internal func generateSessionId(sessionKey: Data) throws -> SecuredSession {
        do {
            // 1. Base64 encode the session key
            let base64Key = sessionKey.base64EncodedString()
            
            // 2. Convert to raw bytes
            let keyBytes = Data(base64Key.utf8)
            
            // 3. Encrypt using RSA-OAEP-SHA256
            let sealed = try self.xenditPublicKey.encrypt(
                algorithm: .rsaEncryptionOAEPSHA256,
                plaintext: keyBytes)
            
            return SecuredSession(key: sessionKey, sealed: sealed)
        } catch {
            throw XenError.generateSessionIdError("")
        }
    }

    /**
     Encrypts data following AES-GCM scheme.
     - Parameter plain: the data to encrypt.
     - Parameter iv: initialization vector randomly generated
     - Parameter sessionKey: sessionKey used to encrypt
     - Throws: `XenError.encryptionError`
               if  there was any issue during encryption.
     - Returns: The encrypted text
     */
    public func encrypt(plain: Data, iv _: Data, sessionKey: Data) throws -> SecuredSession {
        do {
            let iv = AES.randomIV(32)
            let gcm = GCM(iv: iv, mode: .combined)
            let aes = try AES(key: sessionKey.bytes, blockMode: gcm, padding: .noPadding)
            let sealed = try aes.encrypt(plain.bytes)
            return SecuredSession(key: sessionKey, sealed: Data(sealed))
        } catch {
            throw XenError.encryptionError("")
        }
    }

    /**
     Decrypts data that has been encrypted following AES-GCM scheme.
     - Parameter secret: Secret encoded in base64 format.
     - Parameter sessionKey: sessionKey used to encrypt.
     - Parameter iv: initialization vector or nonce in base64 format
     - Throws: `XenError.decryptionError`
                if there was any issue during decryption.
     - Returns: The decrypted text.
     */
    internal func decrypt(secret: String, sessionKey: Data, iv: String) throws -> Data {
        do {
            let secret = Data(base64Encoded: secret)!
            let nonce = Data(base64Encoded: iv)!
            let aesNonce = try! AES.GCM.Nonce(data: nonce)

            let idxTag = secret.index(secret.endIndex, offsetBy: -16)
            let tag = secret[idxTag...]

            let idxCipher = secret.index(secret.startIndex, offsetBy: secret.count - 16)
            let cipher = secret[..<idxCipher]

            let sealed = try! AES.GCM.SealedBox(nonce: aesNonce, ciphertext: cipher, tag: tag)

            if let decryptedData = try? AES.GCM.open(sealed, using: SymmetricKey(data: sessionKey)) {
                return decryptedData
            } else {
                throw XenError.decryptionError("")
            }
        } catch {
            throw XenError.decryptionError("")
        }
    }

    private static func getKeyFromKeychain(tag: String) -> SecKey? {
        var keyRef: AnyObject?
        let attributes: [String: Any] = [
            String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
            String(kSecClass): kSecClassKey,
            String(kSecAttrApplicationTag): tag,
            String(kSecReturnRef): true
        ]
        let status = SecItemCopyMatching(attributes as CFDictionary, &keyRef)
        if status != 0 {
            return nil
        }
        return (keyRef as! SecKey)

    }

    private static func getKeyFromKeychainAsData(tag: String) -> Data? {
        var keyRef: AnyObject?
        let attributes: [String: Any] = [
            String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
            String(kSecClass): kSecClassKey,
            String(kSecAttrApplicationTag): tag,
            String(kSecReturnRef): true
        ]
        let status = SecItemCopyMatching(attributes as CFDictionary, &keyRef)
        if status != 0 {
            return nil
        }
        return keyRef as? Data
    }

    private static func updateKeychain(tag: String, key: Data) -> Bool {
        let attributes: [String: Any] = [
            String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
            String(kSecClass): kSecClassKey,
            String(kSecAttrApplicationTag): tag
        ]
        return SecItemUpdate(attributes as CFDictionary, [String(kSecValueData): key] as CFDictionary) == errSecSuccess
    }

    private static func addToKeychain(tag: String, key: Data) -> Bool {
        let attributes: [String: Any] = [
            String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
            String(kSecClass): kSecClassKey,
            String(kSecAttrApplicationTag): tag,
            String(kSecValueData): key,
            String(kSecReturnPersistentRef): true
        ]
        let status = SecItemAdd(attributes as CFDictionary, nil)
        return status == 0
    }

    private static func createKeyFromData(key: Data) -> SecKey? {
        let attributes: [String: Any] = [
            String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
            String(kSecAttrKeyClass): kSecAttrKeyClassPublic,
            String(kSecAttrKeySizeInBits): key.count * 8
        ]
        let key = SecKeyCreateWithData(key as CFData, attributes as CFDictionary, nil)
        return key
    }
}

private extension SecKey {
    enum KeyType {
        case rsa
        var secAttrKeyTypeValue: CFString {
            switch self {
            case .rsa:
                return kSecAttrKeyTypeRSA
            }
        }
    }

    func encrypt(algorithm: SecKeyAlgorithm, plaintext: Data) throws -> Data {
        var error: Unmanaged<CFError>?
        
        // 1. Verify algorithm support
        guard SecKeyIsAlgorithmSupported(self, .encrypt, .rsaEncryptionOAEPSHA256) else {
            throw XenError.encryptRSAError("RSA-OAEP-SHA256 not supported")
        }
        
        // 2. Perform encryption with OAEP padding
        guard let ciphertext = SecKeyCreateEncryptedData(
            self,
            .rsaEncryptionOAEPSHA256,
            plaintext as CFData,
            &error
        ) as Data? else {
            if let error = error?.takeRetainedValue() {
                throw error
            }
            throw XenError.encryptRSAError("Encryption failed")
        }
        
        return ciphertext
    }
}
