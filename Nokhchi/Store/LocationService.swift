import CoreLocation
import Observation

@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    var location: GeoPoint?
    var errorMessage: String?
    var isRequesting = false
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() {
        location = nil
        isRequesting = true
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse: manager.requestLocation()
        case .denied, .restricted:
            isRequesting = false
            errorMessage = "Разрешите доступ к геопозиции в настройках iPhone для Nokhchi."
        @unknown default:
            isRequesting = false
            errorMessage = "Неизвестное состояние разрешения геопозиции."
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard isRequesting else { return }
        requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isRequesting = false
        guard let latest = locations.last, latest.horizontalAccuracy >= 0 else {
            errorMessage = "Служба геолокации не вернула корректную точку."
            return
        }
        location = GeoPoint(
            latitude: latest.coordinate.latitude, longitude: latest.coordinate.longitude
        )
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isRequesting = false
        errorMessage = "Не удалось определить местоположение: \(error.localizedDescription)"
    }
}
