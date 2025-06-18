import SwiftUI
import MapKit

struct MapKitWrapper: UIViewRepresentable {
    @Binding var locations: [CLLocationCoordinate2D]

    let mapView = MKMapView()

    func makeUIView(context: Context) -> MKMapView { // blue dot showing user location
        mapView.showsUserLocation = true
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {

        for coord in locations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coord
            uiView.addAnnotation(annotation)
        }

        if let last = locations.last { //map centering on available locations
            let region = MKCoordinateRegion(
                center: last,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            uiView.setRegion(region, animated: true) //smoother centering
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
