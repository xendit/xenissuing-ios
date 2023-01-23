import Foundation

public enum XenError: Error {
    case encryptionError
    case decryptionError
    case genericError
    case generateRandomKeyError
    case generateSessionIdError
    case updateKeychainError
    case convertKeyDataError
    case encryptRSAError
}

extension XenError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .genericError:
            return NSLocalizedString("There was an error while using XenIssuing library.", comment: "XenError")
        case .encryptionError:
            return NSLocalizedString("There was an error while trying to encrypt using XenIssuing library.", comment: "XenError")
        case .decryptionError:
            return NSLocalizedString("There was an error while trying to decrypt using XenIssuing library.", comment: "Please make sure you are properly decrypted values.")
        case .generateRandomKeyError:
            return NSLocalizedString("There was an error while generating a random key", comment: "XenError")
        case .generateSessionIdError:
            return NSLocalizedString("There was an error while generating a session id", comment: "XenError")
        case .updateKeychainError:
            return NSLocalizedString("There was an error while tring to update the keychain", comment: "XenError")
        case .convertKeyDataError:
            return NSLocalizedString("There was an error while trying to read the public key data", comment: "XenError")
        case .encryptRSAError:
            return NSLocalizedString("There was an error while trying to encrypt with RSA", comment: "XenError")
        case .generateRandomKeyError:
            return NSLocalizedString("There was an error while generating a random key", comment: "XenError")
        }
    }
}
