//
//  MapView.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 2020/05/24.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: NSViewRepresentable {

    @ObservedObject var location: Location

    var mapView = MKMapView()

    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }

    func makeNSView(context: Context) -> MKMapView {
        let nsView = self.mapView
        nsView.delegate = context.coordinator
        nsView.showsCompass = true
        nsView.showsZoomControls = true

        let pressGesture = NSPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.mapViewPressed(_:)))
        pressGesture.minimumPressDuration = 0.5
        pressGesture.numberOfTouchesRequired = 1
        nsView.addGestureRecognizer(pressGesture)

        context.coordinator.initialize()

        return nsView
    }

    func updateNSView(_ nsView: MKMapView, context: Context) {

    }
}

// MARK: - Preview

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(location: Location())
    }
}
