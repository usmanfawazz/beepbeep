import SwiftUI
import MapKit

struct MapKitWrapper: UIViewRepresentable {
    @Binding var locations: [CLLocationCoordinate2D]
    @Binding var points: [LiftPoint]
    
    
    let mapView = MKMapView()
    
    func makeUIView(context: Context) -> MKMapView { // blue dot showing user location
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
        
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.removeOverlays(uiView.overlays)
        
        for point in points {
            let circle = MKCircle(center: point.coordinate, radius: 30) // meters
            uiView.addOverlay(circle) //overlay
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
    class Coordinator: NSObject, MKMapViewDelegate {
        var didCenter = false
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.fillColor = UIColor.red.withAlphaComponent(0.7)
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
