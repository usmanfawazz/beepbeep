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
        uiView.removeAnnotations(uiView.annotations)

        for coord in locations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coord
            uiView.addAnnotation(annotation)
        }

        if let last = locations.last, !context.coordinator.didCenter { //map centering based on user location
            let region = MKCoordinateRegion(
                center: last,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            uiView.setRegion(region, animated: true)
            context.coordinator.didCenter = true
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    class Coordinator {
        var didCenter = false
    }
}
