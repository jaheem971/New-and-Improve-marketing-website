import CoreLocation
import Foundation
import Observation

/// Wraps CoreLocation. The pilot market is Cannes: when the device is
/// elsewhere (or location is denied) the app uses the demo origin so the
/// venue set still makes sense.
@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    private(set) var origin: Coordinate = MockVenues.demoOrigin
    private(set) var isUsingDemoLocation = true
    private(set) var authorization: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()
    private let pilotRadiusMetres = 25_000.0

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 25
        authorization = manager.authorizationStatus
    }

    var isAuthorized: Bool {
        authorization == .authorizedWhenInUse || authorization == .authorizedAlways
    }

    var placeLabel: String {
        isUsingDemoLocation ? "Cannes · La Croisette (demo)" : "Cannes · near you"
    }

    func requestAccess() {
        manager.requestWhenInUseAuthorization()
    }

    func start() {
        guard isAuthorized else { return }
        manager.startUpdatingLocation()
    }

    func stop() {
        manager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorization = manager.authorizationStatus
        start()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        if coordinate.distance(to: MockVenues.demoOrigin) <= pilotRadiusMetres {
            origin = coordinate
            isUsingDemoLocation = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Keep the last known (or demo) origin; the ranking still works.
    }
}
