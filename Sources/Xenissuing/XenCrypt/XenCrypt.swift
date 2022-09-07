import Crypto
import CryptoSwift
import Foundation

/// https://stackoverflow.com/a/57912525
@available(macOS 10.15, *)
extension SymmetricKey {
    // MARK: - Instance Methods

    /// Serializes a `SymmetricKey` to a Base64-encoded `String`.
    func serialize() -> Data {
        return withUnsafeBytes { body in
            Data(body)
        }
    }
}

protocol Crypto {
    var xenditKey: Data { get }
    func generateRandom() throws -> Data
    func generateSessionId(sessionKey: Data) -> EncryptedMessage
    func encrypt(plain: Data, iv: Data, sessionKey: Data) throws -> EncryptedMessage
    func decrypt(secret: String, sessionKey: Data, iv: String) throws -> Data
}

/// Encapsulates encrypted message and key used as encryption key.
public struct EncryptedMessage {
    let key: Data
    let sealed: Data
}

// MARK: - XenCrypt

@available(macOS 10.15, *)
public class XenCrypt: Crypto {
    /// The key provided by Xendit.
    let xenditKey: Data

    /**
     Initializes XenCrypt with the provided public key.

     - Parameters:
        - xenditKey: The public key provided by Xendit.

     - Returns: Module to help with encryption.
     */
    init(xenditKey: Data) { self.xenditKey = xenditKey }

    /**
     Generates a random 24 bytes keys.
      - Throws: `XenError.generateRandomKeyError`
                if  there was any issue when trying to generate the symmetric key.
      - Returns: the random session key.
      */
    public func generateRandom() throws -> Data {
        do {
            let key = SymmetricKey(size: .bits192)
            return key.serialize()
        } catch {
            throw XenError.generateRandomKeyError
        }
    }

    /**
     Generates Session Id following AES-CBC  scheme using the key provided by Xendit.
     IV used is 16 bytes size.
      - Parameter xenditKey: Secret key `Data` (provided by Xendit).
      - Parameter sessionKey: Random key `Data`.
      - Throws: `XenError.encryptionError`
                if  there was any issue during encryption.
      - Returns: The encrypted text
      */
    public func generateSessionId(sessionKey: Data) -> EncryptedMessage {
        let iv = AES.randomIV(AES.blockSize)
        let aes = try! AES(key: xenditKey.bytes, blockMode: CBC(iv: iv), padding: .pkcs7)
        let sealed = try! aes.encrypt(sessionKey.bytes)
        return EncryptedMessage(key: xenditKey, sealed: Data(iv + sealed))
    }

    /**
     Encrypts data following AES-GCM scheme.
     - Parameter plain: the data to encrupt.
     - Parameter iv: initilization vector randomly generated
     - Parameter sessionKey: sessionKey used to encrypt
     - Throws: `XenError.encryptionError`
               if  there was any issue during encryption.
     - Returns: The encrypted text
     */
    public func encrypt(plain: Data, iv: Data, sessionKey: Data) throws -> EncryptedMessage {
        do {
            let iv = AES.randomIV(32)
            let gcm = GCM(iv: iv, mode: .combined)
            let aes = try AES(key: sessionKey.bytes, blockMode: gcm, padding: .noPadding)
            let sealed = try aes.encrypt(plain.bytes)
            return EncryptedMessage(key: sessionKey, sealed: Data(sealed))
        } catch {
            throw XenError.encryptionError
        }
    }

    /**
     Decrypts data that has been encrypted following AES-GCM scheme.
     - Parameter secret: Secret encoded in base64 format.
     - Parameter sessionKey: sessionKey used to encrypt.
     - Parameter iv: initilization vector or nonce in base64 format
     - Throws: `XenError.decryptionError`
                if there was any issue during decryption.
     - Returns: The decrypted text.
     */
    public func decrypt(secret: String, sessionKey: Data, iv: String) throws -> Data {
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
                throw XenError.decryptionError
            }
        } catch {
            throw XenError.decryptionError
        }
    }
}
