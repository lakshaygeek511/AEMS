//
//  MembersDTO.swift
//  Team Planner New
//
//  Created by VE00YM572 on 08/06/23.
//

import Foundation
public struct MembersDTO: Codable
{
    public var fullName: String?
    public var ein: String?
    
    public init(fullName: String?, ein: String?)
    {
        self.fullName = fullName
        self.ein = ein
    }
    
}

