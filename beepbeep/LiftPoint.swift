import Foundation
import CoreLocation

struct LiftPoint: Codable, Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let altitude: Double
    let timestamp: Date
    let sessionID: UUID?

    enum CodingKeys: String, CodingKey {
        case latitude, longitude, altitude, timestamp, id, sessionID
    }

    init(coordinate: CLLocationCoordinate2D, altitude: Double, timestamp: Date = Date(), sessionID: UUID? = nil) {
        self.coordinate = coordinate
        self.altitude = altitude
        self.timestamp = timestamp
        self.sessionID = sessionID
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        altitude = try container.decode(Double.self, forKey: .altitude)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        sessionID = try? container.decode(UUID.self, forKey: .sessionID)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(sessionID, forKey: .sessionID)
    }
}
