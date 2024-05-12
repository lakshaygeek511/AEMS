
import Foundation

public struct StatusDTO: Codable
{
    public var statuscode: Int?
    public var status: String?

    
    public init(statuscode: Int? , status: String?)
    {
        self.statuscode = statuscode
        self.status = status
    }
    
}
