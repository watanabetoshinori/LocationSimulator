//
//  MapViewCoordinator.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 2020/05/24.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation
import Combine
import MapKit

public extension NSNotification.Name {
    static let MoveCurrentLocation = Notification.Name("MoveCurrentLocation")
}

extension MapView {

    class MapViewCoordinator: NSObject, MKMapViewDelegate {

        let kCurrentLocationIdentifier = "CurrentLocationIdentifier"

        private var parent: MapView

        private var autoMoveTimer: Timer?

        private var cancellables = [AnyCancellable]()

        init(_ parent: MapView) {
            self.parent = parent
        }

        func initialize() {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(move),
                                                   name: .MoveCurrentLocation,
                                                   object: nil)

            parent.location.$coordinate.sink { coordinate in
                if coordinate.isInvalid {
                    self.remove()
                } else {
                    self.animate(to: coordinate)

                    if self.parent.location.isAutoFocusEnabled {
                        self.center(to: coordinate)
                    }

                    self.parent.location.device?.simulate(location: coordinate)
                }
            }
            .store(in: &cancellables)

            parent.location.$isAutoFocusEnabled.filter({ $0 }).sink { _ in
                self.focus()
            }
            .store(in: &cancellables)

            parent.location.$isAutoMoveEnabled.sink { value in
                if value {
                    // Enabled
                    self.autoMoveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
                        self.move()
                    })
                } else {
                    // Diasbled
                    self.autoMoveTimer?.invalidate()
                    self.autoMoveTimer = nil
                }
            }
            .store(in: &cancellables)
        }

        var locationAnnotaton: MKPointAnnotation? {
            parent.mapView.annotations.first as? MKPointAnnotation
        }

        // MARK: - MapView Delegate

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: kCurrentLocationIdentifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: kCurrentLocationIdentifier)
            } else {
                annotationView?.annotation = annotation
            }
            annotationView?.canShowCallout = true
            annotationView?.image = NSImage(named: "UserLocation")
            annotationView?.centerOffset = CGPoint(x: 0, y: 0)

            return annotationView
        }

        // MARK: - Gesture Action

        @objc func mapViewPressed(_ sender: NSPressGestureRecognizer) {
            guard sender.state == .ended else {
                return
            }

            let point = sender.location(in: parent.mapView)
            parent.location.coordinate = parent.mapView.convert(point, toCoordinateFrom: parent.mapView)

            if locationAnnotaton == nil {
                // Add current location

                parent.location.isAutoFocusEnabled  = true

                add()
                focus()

            } else {
                // Replace current location

                remove()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.add()

                    if self.parent.location.isAutoFocusEnabled {
                        self.focus()
                    }
                }
            }
        }

        // MARK: - Managing current location

        private func add() {
            let annotation = MKPointAnnotation()
            annotation.coordinate = parent.location.coordinate
            annotation.title = "Current Location"
            parent.mapView.addAnnotation(annotation)
        }

        @objc func move() {
            if parent.location.coordinate.isInvalid {
                return
            }

            let correctHeading = parent.mapView.camera.heading + parent.location.heading

            let latitude = parent.location.coordinate.latitude
            let longitude = parent.location.coordinate.longitude

            let earthCircle = 2 * .pi * 6371000.0

            let latDistance = parent.location.transportation.distance * cos(correctHeading * .pi / 180)
            let latPerMeter = 360 / earthCircle
            let latDelta = latDistance * latPerMeter
            let newLat = latitude + latDelta

            let lngDistance = parent.location.transportation.distance * sin(correctHeading * .pi / 180)
            let earthRadiusAtLng = 6371000.0 * cos(newLat * .pi / 180)
            let earthCircleAtLng = 2 * .pi * earthRadiusAtLng
            let lngPerMeter = 360 / earthCircleAtLng
            let lngDelta = lngDistance * lngPerMeter
            let newLng = longitude + lngDelta

            parent.location.coordinate = CLLocationCoordinate2D(latitude: newLat, longitude: newLng)
        }

        private func focus() {
            let coordinate = parent.location.coordinate

            if coordinate.isInvalid {
                return
            }

            let currentRegion = parent.mapView.region
            let span = MKCoordinateSpan(latitudeDelta: min(0.002, currentRegion.span.latitudeDelta),
                                        longitudeDelta: min(0.002, currentRegion.span.longitudeDelta))
            let region = MKCoordinateRegion(center: coordinate, span: span)
            parent.mapView.setRegion(region, animated: true)
        }

        private func center(to coordinate: CLLocationCoordinate2D) {
            if coordinate.isInvalid {
                return
            }

            parent.mapView.setCenter(coordinate, animated: true)
        }

        private func animate(to coordinate: CLLocationCoordinate2D) {
            if coordinate.isInvalid {
                return
            }

            let duration: Double = parent.location.isAutoMoveEnabled ? 1.0 : 0.5

            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = duration
                context.timingFunction = CAMediaTimingFunction(name: .linear)
                context.allowsImplicitAnimation = true
                self.locationAnnotaton?.coordinate = coordinate
            }, completionHandler: nil)
        }

        private func remove() {
            guard let annotation = locationAnnotaton else {
                return
            }

            parent.mapView.removeAnnotation(annotation)
        }

    }

}
