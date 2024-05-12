
import Foundation

public struct UserDTO: Codable
{
    public var username:String?
    public var password: String?
    public var fullname:String?
    public var usercode: Int?

    
    public init(username:String?,fullname:String?,password: String?,usercode: Int?)
    {
        self.username = username
        self.password = password
        self.fullname = fullname
        self.usercode = usercode
    }

}
