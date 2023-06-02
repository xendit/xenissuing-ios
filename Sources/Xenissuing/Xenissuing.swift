import Foundation

#if swift(<5.3)
#error("This Swift version is not supported.")
#endif

// MARK: - Xenissuing

@available(macOS 10.15, *)
public enum Xenissuing {
    /**
     Create a secure session used to generate a key and decrypt card data.

     - Parameters:
         - xenditPublicKeyData: Public Key.
         - xenditPublicKeyTag: Public Key Tag. If provided, it will try to check first keychain to get the key data.

     - Returns: Secure session object.
     */
    public static func createSecureSession(xenditPublicKeyData: Data, xenditPublicKeyTag: String? = nil) throws -> SecureSession {
        let secSession: SecureSession = try SecureSession(xenditPublicKeyData: xenditPublicKeyData, xenditPublicKeyTag: xenditPublicKeyTag)
        return secSession
    }
}
