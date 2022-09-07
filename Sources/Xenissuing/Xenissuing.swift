import Foundation

#if swift(<5.3)
#error("This Swift version is not supported.")
#endif

// MARK: - Xenissuing

@available(macOS 10.15, *)
public final class Xenissuing: XenCrypt {
    /**
     Initializes XenIssuing module.

     - Parameters:
        - xenditKey: The key provided by Xendit.

     - Returns: Main module.
     */
    override init(xenditKey: Data) {
        super.init(xenditKey: xenditKey)
    }
}
