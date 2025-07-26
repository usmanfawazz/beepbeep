import SwiftUI
import CoreLocation

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var markedLocations: [CLLocationCoordinate2D] = []
    @State private var liftPoints: [LiftPoint] = []
    @StateObject private var soundAnalyzer = SoundClassifier()
    @State private var sessionActive = false
    @State private var currentSessionPoints: [LiftPoint] = []
    @State private var currentSessionID: UUID? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            MapKitWrapper(locations: $markedLocations, points: $liftPoints)
                .edgesIgnoringSafeArea(.all)

            Button(sessionActive ? "Stop Session" : "Start Session") {
                sessionActive.toggle()

                if sessionActive {
                    currentSessionID = UUID() // Only assign once at session start
                } else {
                    // Save all current session points
                    liftPoints.append(contentsOf: currentSessionPoints)
                    markedLocations.append(contentsOf: currentSessionPoints.map { $0.coordinate })
                    LiftCoordinatesStorage.shared.save(liftPoints)
                    currentSessionPoints.removeAll()
                    currentSessionID = nil // Clear after session ends
                }
            }
            .padding()
            .background(sessionActive ? Color.red : Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .onAppear {
            // Load saved lift points on launch
            liftPoints = LiftCoordinatesStorage.shared.load()
            markedLocations = liftPoints.map { $0.coordinate }

            // Setup beep detection callback
            soundAnalyzer.onRisingBeepDetected = {
                guard sessionActive, let loc = locationManager.currentLocation, let sessionID = currentSessionID else { return }

                let point = LiftPoint(
                    coordinate: loc.coordinate,
                    altitude: loc.altitude,
                    timestamp: Date(),
                    sessionID: sessionID
                )

                currentSessionPoints.append(point)
                print("Location marked: \(loc.coordinate)")
            }

            // Start listening for beeps
            soundAnalyzer.startListening()
        }
    }
}
