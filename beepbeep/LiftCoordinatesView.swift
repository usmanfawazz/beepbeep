import SwiftUI

struct LiftCoordinatesView: View {
    let points: [LiftPoint]

    var body: some View {
        List(points) { point in
            VStack(alignment: .leading) {
                Text("\(point.coordinate.latitude), \(point.coordinate.longitude)")
                    .font(.headline)
                Text("Alt: \(Int(point.altitude))m")
                Text("Time: \(point.timestamp.formatted(date: .numeric, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}
