
import Foundation

public struct ProjectDTO: Codable
{
    public var projectType: Int?
    public var project: String?

    
    public init(projectType:Int?, project:String?)
    {
        self.projectType = projectType
        self.project = project
    }
    
}

