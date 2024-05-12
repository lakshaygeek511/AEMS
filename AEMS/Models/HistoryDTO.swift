
import Foundation

public struct HistoryDTO: Codable
{
    
    public var enquiryno: Int?
    public var address:String?
    public var fullname:String?
    public var email:String?
    public var phoneNo:String?
    public var product:String?
    public var username:String?
    public var enquirydate: Int?
    public var quantity: Int?
    public var latitude: Double?
    public var longitude: Double?
    public var statuscode: Int?

    
    public init(enquiryno: Int? , enquirydate: Int? , quantity: Int? , latitude: Double? , longitude: Double? , statuscode: Int? , address:String? , fullname:String? , email:String? , phoneNo:String? , product:String? , username:String?)
    {
        self.enquiryno = enquiryno
        self.enquirydate = enquirydate
        self.latitude = latitude
        self.longitude = longitude
        self.quantity = quantity
        self.statuscode = statuscode
        self.username = username
        self.product = product
        self.phoneNo = phoneNo
        self.email = email
        self.product = product
        self.address = address
        self.fullname = fullname
    }
    
}
