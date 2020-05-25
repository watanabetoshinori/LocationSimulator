//
//  CLLocationCoordinate2D+Utility.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 2020/05/24.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import MapKit

extension CLLocationCoordinate2D {

    var isInvalid: Bool {
        latitude == kCLLocationCoordinate2DInvalid.latitude
            && longitude == kCLLocationCoordinate2DInvalid.longitude
    }

}
