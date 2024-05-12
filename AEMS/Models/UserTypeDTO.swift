
import Foundation

public struct UserTypeDTO: Codable
{
    public var usercode: Int?
    public var userType: String?

    
    public init(usercode: Int?,userType: String?)
    {
        self.userType = userType
        self.usercode = usercode
    }
    
}

