import Foundation

public enum XenError: Error {
    case encryptionError
    case decryptionError
    case genericError
    case generateRandomKeyError
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
        }
    }
}
