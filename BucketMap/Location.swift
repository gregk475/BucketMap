//
//  Location.swift
//  BucketMap
//
//  Created by Greg Kapp on 2/15/26.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class BucketLocation {
    var title: String
    var streetAddress: String
    var urlString: String
    var notes: String
    var dateAdded: Date
    var isVisited: Bool
    var dateVisited: Date?
    var latitude: Double
    var longitude: Double
    
    init(title: String, streetAddress: String, urlString: String = "", notes: String = "", latitude: Double, longitude: Double) {
        self.title = title
        self.streetAddress = streetAddress
        self.urlString = urlString
        self.notes = notes
        self.dateAdded = .now
        self.isVisited = false
        self.dateVisited = nil
        self.latitude = latitude
        self.longitude = longitude
    }
}
