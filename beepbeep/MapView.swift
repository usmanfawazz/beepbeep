import SwiftUI
import CoreLocation

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var markedLocations: [CLLocationCoordinate2D] = []
    @State private var liftPoints: [LiftPoint] = []
    @StateObject private var soundAnalyzer = SoundClassifier()
    @State private var sessionActive = false
    @State private var currentSessionPoints: [LiftPoint] = []


    var body: some View {
        ZStack(alignment: .bottom) {
            MapKitWrapper(locations: $markedLocations, points: $liftPoints)
                .edgesIgnoringSafeArea(.all)
            Button(sessionActive ? "Stop Session" : "Start Session") {
                sessionActive.toggle()
                
                if !sessionActive {
                    liftPoints.append(contentsOf: currentSessionPoints) //save points after sesion ends
                    markedLocations.append(contentsOf: currentSessionPoints.map { $0.coordinate })
                    LiftCoordinatesStorage.shared.save(liftPoints)
                    currentSessionPoints.removeAll()
                }
            }
            .padding()
            .background(sessionActive ? Color.red : Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        
        .onAppear {
            liftPoints = LiftCoordinatesStorage.shared.load()
            markedLocations = liftPoints.map { $0.coordinate } //convert to coordinates and save
            soundAnalyzer.onRisingBeepDetected = {
                guard sessionActive, let loc = locationManager.currentLocation else { return }
                let point = LiftPoint(
                    coordinate: loc.coordinate,
                    altitude: loc.altitude
                )
                currentSessionPoints.append(point)
                liftPoints.append(point)
                markedLocations.append(loc.coordinate)
                LiftCoordinatesStorage.shared.save(liftPoints)
                print("Location marked: \(loc.coordinate)")
                }
                
            soundAnalyzer.startListening()

            }
        }
    }
