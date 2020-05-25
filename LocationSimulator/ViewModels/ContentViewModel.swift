//
//  ContentViewModel.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 2020/05/24.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {

    var location: Location

    @Published var isCurrentLocationExists = true

    @Published var isAutoMoveEnabled = false

    @Published var transportationImage = Transportation.walk.text

    @Published var radians: Double = 0

    @Published var showIntroduction = true

    private var cancellables = [AnyCancellable]()

    // MARK: - Initializing ViewModel

    init(_ location: Location) {
        self.location = location

        $radians.sink { radians in
            self.location.heading = (radians < 0 ? 360 : 0) + 60 * radians
        }
        .store(in: &cancellables)

        location.$coordinate.sink { value in
            self.isCurrentLocationExists = !value.isInvalid
        }
        .store(in: &cancellables)

        location.$isAutoMoveEnabled.sink { value in
            self.isAutoMoveEnabled = value
        }
        .store(in: &cancellables)

        location.$transportation.sink { value in
            self.transportationImage = value.text
        }
        .store(in: &cancellables)

        location.$device.sink { value in
            self.showIntroduction = (value == nil)
        }
        .store(in: &cancellables)
    }

    // MARK: - Actions

    func movePressed() {
        if location.isAutoMoveEnabled {
            location.isAutoMoveEnabled = false
            return
        }

        NotificationCenter.default.post(name: .MoveCurrentLocation, object: nil)
    }

    func moveLongPresed() {
        location.isAutoMoveEnabled.toggle()
    }

}
