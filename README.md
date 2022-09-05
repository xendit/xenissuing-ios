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
