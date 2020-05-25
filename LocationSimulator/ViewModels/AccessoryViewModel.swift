//
//  AccessoryViewModel.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 2020/05/24.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation
import Combine
import MapKit

class AccessoryViewModel: ObservableObject {

    var location: Location

    @Published var selectedType = 0

    @Published var isCurrentLocationExists = true

    @Published var isAutoFocusEnabled = false

    var transportationLabels: [String] {
        Transportation.allCases.map { $0.text }
    }

    private var cancellables = [AnyCancellable]()

    // MARK: - Initializing ViewModel

    init(_ location: Location) {
        self.location = location

        $selectedType.sink { value in
            self.location.transportation = Transportation(rawValue: value) ?? .walk
        }
        .store(in: &cancellables)

        location.$coordinate.sink { value in
            self.isCurrentLocationExists = !value.isInvalid
        }
        .store(in: &cancellables)

        location.$isAutoFocusEnabled.sink { value in
            self.isAutoFocusEnabled = value
        }
        .store(in: &cancellables)
    }

    // MARK: - Actions

    func currentLocationPressed() {
        location.isAutoFocusEnabled.toggle()
    }

    func resetPressed() {
        location.isAutoFocusEnabled = false
        location.coordinate = kCLLocationCoordinate2DInvalid
        location.device?.reset()
        location.device = nil
    }

}
