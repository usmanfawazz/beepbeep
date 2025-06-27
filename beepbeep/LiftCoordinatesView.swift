import SwiftUI

struct LiftCoordinatesView: View {
    let points: [LiftPoint]
    
    var body: some View {
        List {
            ForEach(groupedPoints, id: \.0) { (label, group) in
                Section(header: Text(label)) {
                    ForEach(group) { point in
                        VStack(alignment: .leading) {
                            Text("Lat: \(point.coordinate.latitude), Lon: \(point.coordinate.longitude)")
                            Text("Alt: \(Int(point.altitude)) ft") //changed to feet, is inaccurate, need to fix
                            Text("Time: \(point.timestamp.formatted(date: .omitted, time: .shortened))")

                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        
    }
    private var groupedPoints: [(String, [LiftPoint])] {
        let grouped = Dictionary(grouping: points) { point in
            Calendar.current.startOfDay(for: point.timestamp)
        }
        
        let sortedDates = grouped.keys.sorted(by: >) // newest dates first
        
        return sortedDates.map { date in
            let label: String
            if Calendar.current.isDateInToday(date) {
                label = "Today"
            } else if Calendar.current.isDateInYesterday(date) {
                label = "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                label = formatter.string(from: date)
            }
            
            let sortedPoints = (grouped[date] ?? []).sorted(by: { $0.timestamp > $1.timestamp })
            return (label, sortedPoints)
        }
    }
}
