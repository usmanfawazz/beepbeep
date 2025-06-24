import SwiftUI
import CoreLocation

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var markedLocations: [CLLocationCoordinate2D] = []
    @State private var liftPoints: [LiftPoint] = []
    @StateObject private var soundAnalyzer = SoundClassifier()


    var body: some View {
        ZStack(alignment: .bottom) {
            MapKitWrapper(locations: $markedLocations)
                .edgesIgnoringSafeArea(.all)

        }
        .onAppear {
            liftPoints = LiftCoordinatesStorage.shared.load()
            markedLocations = liftPoints.map { $0.coordinate } //convert to coordinates and save
            soundAnalyzer.onRisingBeepDetected = {
                    if let loc = locationManager.currentLocation {
                        let point = LiftPoint(
                            coordinate: loc.coordinate,
                            altitude: loc.altitude
                        )
                        liftPoints.append(point)
                        markedLocations.append(loc.coordinate)
                        LiftCoordinatesStorage.shared.save(liftPoints)
                        print("Location marked: \(loc.coordinate)")
                    }
                }
                soundAnalyzer.startListening()
            
        }
    }
}
