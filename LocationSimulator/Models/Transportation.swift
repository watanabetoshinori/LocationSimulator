//
//  Transportation.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 2020/05/24.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation

enum Transportation: Int, CaseIterable {
    case walk = 0
    case cycle
    case car

    var text: String {
        switch self {
        case .walk:
            return "Walk"
        case .cycle:
            return "Cycle"
        case .car:
            return "Car"
        }
    }

    var distance: Double {
        switch self {
        case .walk:
            return 1.38 // 5km/h
        case .cycle:
            return 4.2  // 15km/h
        case .car:
            return 11.1 // 40km/h
        }
    }

}
