//
//  MarkersDTO.swift
//  Yamaha Maps
//
//  Created by VE00YM572 on 01/07/23.
//

import Foundation

public struct MarkersDTO: Codable
{
    public var allocationno: Int
    public var latitude: String?
    public var longitude: String?

    
    public init(allocationno:Int, latitude: String?, longitude: String?)
    {
        self.allocationno = allocationno
        self.latitude = latitude
        self.longitude = longitude
    }
    
}
