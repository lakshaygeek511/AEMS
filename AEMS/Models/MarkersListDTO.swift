//
//  MarkersListDTO.swift
//  Yamaha Maps
//
//  Created by VE00YM572 on 04/07/23.
//

import Foundation


public struct MarkersListDTO: Codable
{
    public var markers: [MarkersDTO]

    public init(markers: [MarkersDTO])
    {
        self.markers = markers
    }
    
}
