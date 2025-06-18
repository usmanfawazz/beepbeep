import SwiftUI
import CoreLocation

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var markedLocations: [CLLocationCoordinate2D] = []
    @State private var liftPoints: [LiftPoint] = []

    var body: some View {
        ZStack(alignment: .bottom) {
            MapKitWrapper(locations: $markedLocations)
                .edgesIgnoringSafeArea(.all)

            Button("Mark Current Location") {
                if let loc = locationManager.currentLocation {
                    let point = LiftPoint(
                        coordinate: loc.coordinate,
                        altitude: loc.altitude
                    )
                    liftPoints.append(point)
                    markedLocations.append(loc.coordinate)
                    LiftCoordinatesStorage.shared.save(liftPoints)
                    print("Marked: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
                } else {
                    print("Location not available.")
                }
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .foregroundColor(.white)
            .padding(.bottom, 30)
        }
        .onAppear {
            liftPoints = LiftCoordinatesStorage.shared.load()
            markedLocations = liftPoints.map { $0.coordinate }
        }
    }
}
