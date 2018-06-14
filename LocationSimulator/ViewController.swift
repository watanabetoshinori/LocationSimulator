//
//  ViewController.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 6/11/18.
//  Copyright © 2018 Watanabe Toshinori. All rights reserved.
//

import Cocoa
import MapKit
import CoreLocation

let kAnnotationViewCurrentLocationIdentifier = "AnnotationViewCurrentLocationIdentifier"

public extension NSNotification.Name {
    static let AutoFoucusCurrentLocationDidChanged = Notification.Name("AutoFoucusCurrentLocationDidChanged")
}

class ViewController: NSViewController, MKMapViewDelegate, NSTableViewDataSource, NSTableViewDelegate {
    
    // MARK: - Enum

    enum AutoMoveState {
        case manual
        case auto
    }
    
    enum MoveType: Int {
        case walk = 0
        case cycle
        case car
        
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
    
    // MARK: - UI

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var moveHeadingShadowView: NSImageView!

    @IBOutlet weak var moveHeadingView: NSImageView!

    @IBOutlet weak var moveButton: NSButton!

    @IBOutlet weak var sideBoxLeadingConstraint: NSLayoutConstraint!
    
    // MARK: - Properties

    var currentLocation: MKPointAnnotation? {
        didSet {
            if currentLocation != nil {
                moveHeadingShadowView.isHidden = false
                moveHeadingView.isHidden = false
                moveButton.isHidden = false
            } else {
                moveHeadingShadowView.isHidden = true
                moveHeadingView.isHidden = true
                moveButton.isHidden = true
            }
        }
    }

    var isHideSideBox = true {
        didSet {
            if isHideSideBox {
                sideBoxLeadingConstraint.constant = -211
            } else {
                sideBoxLeadingConstraint.constant = -1
            }
        }
    }

    var isAutoFocusCurrentLocation = false {
        didSet {
            if isAutoFocusCurrentLocation == true,
                let currentLocation = currentLocation {
                // Zoom to Current Location
                let currentRegion = mapView.region
                let span = MKCoordinateSpan(latitudeDelta: min(0.002, currentRegion.span.latitudeDelta),
                                            longitudeDelta: min(0.002, currentRegion.span.longitudeDelta))
                let region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
                mapView.setRegion(region, animated: true)
            }

            NotificationCenter.default.post(name: .AutoFoucusCurrentLocationDidChanged, object: isAutoFocusCurrentLocation)
        }
    }

    var autoMoveState: AutoMoveState = .manual {
        didSet {
            switch autoMoveState {
            case .manual:
                moveButton.image = #imageLiteral(resourceName: "MoveButton")

                autoMoveTimer?.invalidate()
                autoMoveTimer = nil

            case .auto:
                moveButton.image = #imageLiteral(resourceName: "MoveButton_Auto")

                autoMoveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
                    self.move()
                })
            }
        }
    }
    
    var moveType: MoveType = .walk {
        didSet {
            print(moveType.rawValue)
        }
    }

    private var autoMoveTimer: Timer?
    
    private var device: Device?

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide side box
        sideBoxLeadingConstraint.constant = -211

        // Hide move controls
        moveHeadingShadowView.isHidden = true
        moveHeadingView.isHidden = true
        moveButton.isHidden = true

        // Add gestures
        let mapPressGesture = NSPressGestureRecognizer(target: self, action: #selector(mapViewPressed(_:)))
        mapPressGesture.minimumPressDuration = 0.5
        mapPressGesture.numberOfTouchesRequired = 1
        mapView.addGestureRecognizer(mapPressGesture)

        let headingPressGesture = NSPressGestureRecognizer(target: self, action: #selector(headingViewPressed(_:)))
        headingPressGesture.minimumPressDuration = 0.1
        headingPressGesture.numberOfTouchesRequired = 1
        moveHeadingView.addGestureRecognizer(headingPressGesture)

        let moveClickGesture = NSClickGestureRecognizer(target: self, action: #selector(moveClicked(_:)))
        moveClickGesture.numberOfTouchesRequired = 1
        moveButton.addGestureRecognizer(moveClickGesture)

        let moveLongPressGesture = NSPressGestureRecognizer(target: self, action: #selector(moveLongPressed(_:)))
        moveLongPressGesture.minimumPressDuration = 1.0
        moveLongPressGesture.numberOfTouchesRequired = 1
        moveButton.addGestureRecognizer(moveLongPressGesture)
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    // MARK: - Map view delegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let pointAnnotation = annotation as? MKPointAnnotation,
            pointAnnotation == self.currentLocation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: kAnnotationViewCurrentLocationIdentifier)
            if annotationView == nil {
                annotationView = UserLocationAnnotationView(annotation: annotation, reuseIdentifier: kAnnotationViewCurrentLocationIdentifier)
            } else {
                annotationView?.annotation = annotation
            }
            annotationView?.canShowCallout = true
            annotationView?.image = #imageLiteral(resourceName: "UserLocation")
            annotationView?.centerOffset = CGPoint(x: 0, y: 0)

            return annotationView
        }
        
        return nil
    }

    // MARK: - Gestures Actions

    @objc func mapViewPressed(_ sender: NSPressGestureRecognizer) {
        if sender.state == .ended {
            let loc = sender.location(in: mapView)
            let coordinate = mapView.convert(loc, toCoordinateFrom: mapView)

            if currentLocation == nil {
                // Set current location
                addCurrentLocation(coordinate: coordinate)
            } else {
                updateCurrentLocation(coordinate: coordinate)
            }
        }
    }

    @objc func headingViewPressed(_ sender: NSClickGestureRecognizer) {
        switch sender.state {
        case .changed, .ended:
            let loc = sender.location(in: moveHeadingView)

            moveHeadingView.setAnchorPoint(CGPoint(x: 0.5, y: 0.5))

            let dx = loc.x - moveHeadingView.frame.width / 2
            let dy = loc.y - moveHeadingView.frame.height / 2
            let angle = atan2(-dx, dy)

            moveHeadingView.layer?.transform = CATransform3DMakeRotation(angle, 0, 0, 1)

        default:
            break
        }
    }

    @objc func moveClicked(_ sender: NSClickGestureRecognizer) {
        switch sender.state {
        case .ended:
            switch autoMoveState {
            case .manual:
                move()

            case .auto:
                // Disable auto move
                autoMoveState = .manual
            }

        default:
            break
        }
    }

    @objc func moveLongPressed(_ sender: NSPressGestureRecognizer) {
        switch sender.state {
        case .began:
            switch autoMoveState {
            case .manual:
                // Enable auto move
                autoMoveState = .auto

            case .auto:
                // Disable auto move
                autoMoveState = .manual
            }

        default:
            break
        }
    }

    // MARK: - Managing Current Location

    func addCurrentLocation(coordinate: CLLocationCoordinate2D) {
        if loadDevice() == false {
            return
        }

        let currentLocation = MKPointAnnotation()
        currentLocation.coordinate = coordinate
        currentLocation.title = "Current Location"

        mapView.addAnnotation(currentLocation)

        self.currentLocation = currentLocation

        isAutoFocusCurrentLocation = true

        device?.simulateLocation(coordinate)
    }
    
    func updateCurrentLocation(coordinate: CLLocationCoordinate2D) {
        currentLocation?.coordinate = coordinate
        
        if isAutoFocusCurrentLocation {
            mapView.setCenter(coordinate, animated: true)
        }

        device?.simulateLocation(coordinate)
    }

    // MARK: - Moving Current Location

    func move() {
        let transform = moveHeadingView.layer!.transform
        let angle = atan2(transform.m12, transform.m11)

        let heading: Double = (angle >= 0 ? 360 : 0) - 60 * Double(angle)

        move(distance: moveType.distance, heading: heading)
    }

    func move(distance: Double = 0.0, heading: Double = 0.0) {
        guard let currentLocation = currentLocation else {
            return
        }

        let correctHeading = mapView.camera.heading + heading

        let latitude = currentLocation.coordinate.latitude
        let longitude = currentLocation.coordinate.longitude

        let earthCircle = 2 * .pi * 6371000.0

        let latDistance = distance * cos(correctHeading * .pi / 180)
        let latPerMeter = 360 / earthCircle
        let latDelta = latDistance * latPerMeter
        let newLat = latitude + latDelta

        let lngDistance = distance * sin(correctHeading * .pi / 180)
        let earthRadiusAtLng = 6371000.0 * cos(newLat * .pi / 180)
        let earthCircleAtLng = 2 * .pi * earthRadiusAtLng
        let lngPerMeter = 360 / earthCircleAtLng
        let lngDelta = lngDistance * lngPerMeter
        let newLng = longitude + lngDelta
        
        let duration: Double = (autoMoveState == .auto) ? 1.0 : 0.5

        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            context.allowsImplicitAnimation = true
            currentLocation.coordinate = CLLocationCoordinate2D(latitude: newLat, longitude: newLng)
        }, completionHandler: nil)

        if isAutoFocusCurrentLocation {
            mapView.setCenter(currentLocation.coordinate, animated: true)
        }
        
        device?.simulateLocation(currentLocation.coordinate)
    }
    
    // MARK: - Disable Location Simulate

    func disableSimulation() {
        if let currentLocation = currentLocation {
            mapView.removeAnnotation(currentLocation)
            self.currentLocation = nil
        }

        isAutoFocusCurrentLocation = false
        
        autoMoveState = .manual
        
        device?.disableSimulation()
    }
    
    func loadDevice() -> Bool {
        if device != nil {
            return true
        }
        
        self.device = Device.findConnectedDevice()
        
        if self.device != nil {
            return true
        }
        
        let alert = NSAlert()
        alert.messageText = "Device not connected"
        alert.informativeText = "No device connected.\nPlease connect the device and trust this computer."
        alert.alertStyle = .critical
        alert.runModal()
        
        return false
    }

}
