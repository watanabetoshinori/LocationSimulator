//
//  Location.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 2020/05/24.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation
import MapKit

class Location: ObservableObject {

    @Published var transportation: Transportation = .walk

    @Published var coordinate = kCLLocationCoordinate2DInvalid

    @Published var heading: Double = 0

    @Published var isAutoMoveEnabled = false

    @Published var isAutoFocusEnabled = false

    @Published var device: Device?

}
