![Swift support](https://img.shields.io/badge/Swift-5.3%20%7C%205.4%20%7C%205.5%20%7C%205.6-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/apple/swift-package-manager)
# Xenissuing 

This SDK comprises of the following modules :
- XenCrypt: this module handles encryption between XenIssuing and your iOS application.

## XenCrypt

XenCrypt is a module to help you set up encryption between XenIssuing and your application.

### Requirements

To be able to use XenIssuing, you will need to use a private key provided by Xendit.

### Usage
```swift
import Xenissuing

do {
    let xenKey = Data(base64EncodedString: "BASE64_ENCODED_KEY_PROVIDED_BY_XENDIT")
    let xenIssuing = Xenissuing(xenditKey: xenKey)
    let encrypted, sessionKey = xenissuing.encrypt("123".data(using: .utf8))
} catch {
    throw Xenissuing.genericError()
}

```
