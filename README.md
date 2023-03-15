![Swift support](https://img.shields.io/badge/Swift-5.3%20%7C%205.4%20%7C%205.5%20%7C%205.6-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/apple/swift-package-manager)
# Xenissuing 

This SDK comprises of the following modules :
- SecureSession: this module handles encryption between XenIssuing and your iOS application.
## Requirements

To be able to use XenIssuing, you will need to use the public key provided by Xendit.

## Usage


### SecureSession

SecureSession is a module to help you set up encryption between XenIssuing and your application.

It includes several methods:
- `generateSessionId` will encrypt a session key randomly generated used for asymmetric encryption with Xenissuing.
- `encrypt` would be used when setting sensitive data.
- `decrypt` would be used whenever receiving sensitive data from Xenissuing.


### Session ID

```swift
let xen = try! Xenissuing(xenditPublicKeyData: Data(base64Encoded: "BASE64_PUBLIC_KEY", options: .ignoreUnknownCharacters)!)
let sessionKey = try! xen.generateRandom()
let sessionId = try! xen.generateSessionId(sessionKey: sessionKey.base64EncodedString().data(using: .utf8)!)
let sealed = sessionId.sealed // Data
```

### Encryption

```swift
import Xenissuing

let xen = try! Xenissuing(xenditPublicKeyData: Data(base64Encoded: "BASE64_PUBLIC_KEY", options: .ignoreUnknownCharacters)!)
let nonce = try! xen.generateRandom()
let privateKey = try! xen.generateRandom()
let encrypted = try! xen.encrypt(plain: "hTlNMg4CJZVdTIfXBehfxcU0XQ==".data(using: .utf8)!, iv: nonce, sessionKey: privateKey)
let sealed = encrypted.sealed  // sealed message
```
