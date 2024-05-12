
import Foundation

public struct PracticeDTO: Codable
{
    public var practiceType: Int?
    public var practice: String?

    
    public init(practiceType:Int?, practice:String?)
    {
        self.practiceType = practiceType
        self.practice = practice
    }
    
}

