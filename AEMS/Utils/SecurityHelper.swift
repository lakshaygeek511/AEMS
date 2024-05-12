import Foundation
import CommonCrypto

/***********************************ENCRYPTION AND DECRYPTION*****************************/

extension String {

    
    /// Encrypt the string (AES-256)
    func aesEncrypt() -> String? {
        if let keyData = ENC_DEC_KEY.data(using: String.Encoding.utf8),
            let data = self.data(using: String.Encoding.utf8),
            let cryptData    = NSMutableData(length: Int((data.count)) + 2*kCCBlockSizeAES128) {


            let keyLength              = size_t(2*kCCKeySizeAES128)
            let operation: CCOperation = UInt32(kCCEncrypt)
            let algoritm:  CCAlgorithm = UInt32(2*kCCAlgorithmAES128)
            let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding)



            var numBytesEncrypted :size_t = 0

            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      (keyData as NSData).bytes, keyLength,
                                      ENC_DEC_IV,
                                      (data as NSData).bytes, data.count,
                                      cryptData.mutableBytes, cryptData.length,
                                      &numBytesEncrypted)

            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = Int(numBytesEncrypted)
                let base64cryptString = cryptData.base64EncodedString(options: .lineLength64Characters)
                return base64cryptString


            }
            else {
                return nil
            }
        }
        return nil
    }

    /// Decrypt the string (AES-256)
    func aesDecrypt() -> String? {
        if let keyData = ENC_DEC_KEY.data(using: String.Encoding.utf8),
            let data = NSData(base64Encoded: self, options: .ignoreUnknownCharacters),
            let cryptData    = NSMutableData(length: Int((data.length)) + 2*kCCBlockSizeAES128) {

            let keyLength              = size_t(2*kCCKeySizeAES128)
            let operation: CCOperation = UInt32(kCCDecrypt)
            let algoritm:  CCAlgorithm = UInt32(2*kCCAlgorithmAES128)
            let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding)

            var numBytesEncrypted :size_t = 0

            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      (keyData as NSData).bytes, keyLength,
                                      ENC_DEC_IV,
                                      data.bytes, data.length,
                                      cryptData.mutableBytes, cryptData.length,
                                      &numBytesEncrypted)

            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = Int(numBytesEncrypted)
                let unencryptedMessage = String(data: cryptData as Data, encoding:String.Encoding.utf8)
                return unencryptedMessage
            }
            else {
                return nil
            }
        }
        return nil
    }
    
}


