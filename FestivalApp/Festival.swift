//
//  Festival.swift
//  FestivalApp
//
//  Created by Ben Gray on 29/07/2015.
//  Copyright (c) 2015 YRS. All rights reserved.
//

import UIKit
import CoreLocation

class Festival: NSObject {
    var parseId: String?
    var id = 0
    var name: String
    var coordinate: CLLocationCoordinate2D?
    var postcode: String?
    var street: String?
    var metroId: Int?
    var date: NSDate?
    var lineUp: [Artist]?
    
    init(id: Int,
        name: String,
        coordinate: CLLocationCoordinate2D?,
        postcode: String?,
        street: String?,
        metroId: Int?)
    {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.postcode = postcode
        self.street = street
        self.metroId = metroId
    }
    
}

class Artist {
    var parseId: String?
    var id: Int
    var name: String
    var liked: Bool!
    var disliked: Bool!
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
}

class RoutePart {
    var toName: String
    var mode: String
    var departureTime: String
    var arrivalTime: String
    var duration: String
    var coordinates: [CLLocationCoordinate2D]!
    
    init(toName: String,
        mode: String,
        departureTime: String,
        arrivalTime: String,
        duration: String,
        coordinates: [CLLocationCoordinate2D]!)
    {
        self.toName = toName
        self.mode = mode
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.duration = duration
        self.coordinates = coordinates
    }
}
