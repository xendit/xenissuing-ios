![Swift support](https://img.shields.io/badge/Swift-5.3%20%7C%205.4%20%7C%205.5%20%7C%205.6-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/apple/swift-package-manager)
# Xenissuing 

The XenIssuing SDK provides a secure way to handle sensitive operations in your iOS applications. This SDK includes:
- **SecureSession**: A module that ensures encrypted communication between your application and Xendit's services.

## Prerequisites

- iOS 10.15 or later
- Swift 5.0 or later
- A public key from Xendit (Contact Xendit to obtain this)

## Usage

### Creating a Secure Session

```swift
import Xenissuing

let publicKey = """
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA... // Your RSA public key without header/footer
"""

do {
    // Create secure session
    let secureSession = try Xenissuing.createSecureSession(
        xenditPublicKeyData: Data(base64Encoded: publicKey)!
    )
    
    // Get session ID for API authentication
    let sessionId = secureSession.getSessionId().base64EncodedString()
    
    // Important: URL encode the session ID as it will be used as a URL parameter
    let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
    let encodedSessionId = sessionId.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? ""
    
    // Use encodedSessionId in API requests
    let apiUrl = "https://api.xendit.co/card_issuing/cards/{cardId}/pan?session_id=\(encodedSessionId)"
} catch {
    print("Error:", error)
}
```

### Public Key Format

The public key should be:
- An RSA public key provided by Xendit
- Without the "-----BEGIN PUBLIC KEY-----" and "-----END PUBLIC KEY-----" headers
- A single continuous string (can use Swift multi-line string format for readability)

Example format:
```swift
let publicKey = """
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
"""
```

### Session ID Usage

The session ID must be URL encoded because:
- It contains base64 characters that may include '+' and '/'
- It will be used as a URL parameter in API requests
- URL encoding ensures safe transmission of the session ID in HTTP requests

Example API usage:
```swift
let apiUrl = "https://api.xendit.co/card_issuing/cards/\(cardId)/pan?session_id=\(encodedSessionId)"
```

### Decrypting Card Data

When you receive encrypted card data from Xendit's API:

```swift
do {
    let decryptedData = try secureSession.decryptCardData(
        secret: encryptedCardData, // Base64 encoded encrypted data
        iv: initializationVector   // Base64 encoded IV
    )
    
    // Process the decrypted card data
    let cardInfo = String(data: decryptedData, encoding: .utf8)
} catch {
    print("Decryption error:", error)
}
```

## Support

For issues, questions, or assistance, please reach out to the XenIssuing team at Xendit.
- Email: xenissuing@xendit.co
- API Documentation: https://developers.xendit.co
