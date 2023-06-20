![Swift support](https://img.shields.io/badge/Swift-5.3%20%7C%205.4%20%7C%205.5%20%7C%205.6-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/apple/swift-package-manager)
# Xenissuing 

The XenIssuing SDK includes a collection of modules designed to handle sensitive operations with ease and security in your iOS applications. Notably:
- SecureSession: This module is responsible for ensuring encrypted communication between the XenIssuing SDK and your iOS application.

## Prerequisites

To utilize the XenIssuing SDK, a public key granted by Xendit is required. You can obtain this key by contacting Xendit directly.

## Usage

### Establishing Secure Sessions

The SecureSession module aids in establishing an encrypted communication link between the XenIssuing SDK and your application. Below is a Swift example demonstrating how to create a secure session and decrypt card data:

```swift
import Xenissuing

let secureSession = try Xenissuing.createSecureSession(xenditPublicKeyData: Data(base64Encoded: validPublicKey)!)
let sessionId = secureSession.getKey().base64EncodedString()

let decryptedData = secureSession.decryptCardData(secret: secret, iv: iv)
```
