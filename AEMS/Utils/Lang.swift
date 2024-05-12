
import UIKit

class Lang {
    
    /// Get the Localizable text
    /// - Parameter key: key paremeter
    static func getLocalizedString (fromKey key: String) -> String{
       return NSLocalizedString(key, comment: "")
         
    }
    
}

