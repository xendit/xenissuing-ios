import Foundation

public enum XenError: Error {
    case encryptionError(String)
    case decryptionError(String)
    case genericError(String)
    case generateRandomKeyError(String)
    case generateSessionIdError(String)
    case updateKeychainError(String)
    case convertKeyDataError(String)
    case encryptRSAError(String)
    static let encryptionErrorDefaultMessage: String = "There was an error while trying to encrypt using XenIssuing library."
    static let decryptionErrorDefaultMessage: String = "There was an error while trying to decrypt using XenIssuing library."
    static let genericErrorDefaultMessage: String = "There was an error while using XenIssuing library."
    static let generateRandomKeyErrorDefaultMessage: String = "There was an error while generating a random key."
    static let generateSessionIdErrorDefaultMessage: String = "There was an error while generating a session id."
    static let convertKeyDataErrorDefaultMessage: String = "There was an error while trying to read the public key data."
    static let updateKeychainErrorDefaultMessage: String = "There was an error while trying to update the keychain."
    static let encryptRSAErrorDefaultMessage: String = "There was an error while trying to encrypt with RSA."

    var localizedDescription: String {
        switch self {
            case .encryptionError(let message):
                return message.isEmpty ? XenError.encryptionErrorDefaultMessage : message
            case .decryptionError(let message):
                return message.isEmpty ? XenError.decryptionErrorDefaultMessage : message
            case .genericError(let message):
                return message.isEmpty ? XenError.genericErrorDefaultMessage : message
            case .generateRandomKeyError(let message):
                return message.isEmpty ? XenError.generateRandomKeyErrorDefaultMessage : message
            case .generateSessionIdError(let message):
                return message.isEmpty ? XenError.generateSessionIdErrorDefaultMessage : message
            case .updateKeychainError(let message):
                return message.isEmpty ? XenError.convertKeyDataErrorDefaultMessage : message
            case .convertKeyDataError(let message):
                return message.isEmpty ? XenError.updateKeychainErrorDefaultMessage : message
            case .encryptRSAError(let message):
                return message.isEmpty ? XenError.encryptRSAErrorDefaultMessage : message
        }
    }
}
