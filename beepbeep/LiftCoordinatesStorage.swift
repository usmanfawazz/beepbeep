import Foundation

class LiftCoordinatesStorage {
    static let shared = LiftCoordinatesStorage() //for access anyehere in app avoid data copies
    private let fileName = "liftpoints.json"

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
    }

    func save(_ points: [LiftPoint]) {
        do {
            let data = try JSONEncoder().encode(points) //convert array to raw data with errir handling
            try data.write(to: fileURL)
            print("Lift points saved.")
        } catch {
            print("Failed to save lift points: \(error)")
        }
    }

    func load() -> [LiftPoint] {
        do {
            let data = try Data(contentsOf: fileURL)
            let points = try JSONDecoder().decode([LiftPoint].self, from: data)
            print("Loaded \(points.count) lift points.")
            return points
        } catch {
            print("No saved lift points found or error: \(error)")
            return []
        }
    }
}
