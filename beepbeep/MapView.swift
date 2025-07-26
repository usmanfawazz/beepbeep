import SwiftUI
import CoreLocation

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var soundAnalyzer = SoundClassifier()
    
    @State private var liftPoints: [LiftPoint] = []
    @State private var currentSessionPoints: [LiftPoint] = []
    @State private var markedLocations: [CLLocationCoordinate2D] = []
    
    @State private var sessionActive = false
    @State private var currentSessionID: UUID? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            MapKitWrapper(locations: $markedLocations, points: $liftPoints)
                .edgesIgnoringSafeArea(.all)

            sessionToggleButton
        }
        .onAppear(perform: setup)
    }

    private var sessionToggleButton: some View {
        Button(sessionActive ? "Stop Session" : "Start Session") {
            sessionActive.toggle()
            handleSessionToggle()
        }
        .padding()
        .background(sessionActive ? Color.red : Color.green)
        .foregroundColor(.white)
        .cornerRadius(10)
    }

    private func setup() {
        liftPoints = LiftCoordinatesStorage.shared.load()
        markedLocations = liftPoints.map { $0.coordinate }

        soundAnalyzer.onRisingBeepDetected = {
            guard sessionActive,
                  let location = locationManager.currentLocation,
                  let sessionID = currentSessionID else { return }

            let newPoint = LiftPoint(
                coordinate: location.coordinate,
                altitude: location.altitude,
                timestamp: Date(),
                sessionID: sessionID
            )

            currentSessionPoints.append(newPoint)
            print("Location marked: \(location.coordinate)")
        }

        soundAnalyzer.startListening()
    }

    private func handleSessionToggle() {
        if sessionActive {
            currentSessionID = UUID()
        } else {
            liftPoints.append(contentsOf: currentSessionPoints)
            markedLocations.append(contentsOf: currentSessionPoints.map { $0.coordinate })
            LiftCoordinatesStorage.shared.save(liftPoints)
            currentSessionPoints.removeAll()
            currentSessionID = nil
        }
    }
}
