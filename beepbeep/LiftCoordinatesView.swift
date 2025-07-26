import SwiftUI

struct LiftCoordinatesView: View {
    let points: [LiftPoint]
    
    var body: some View {
        List {
            ForEach(groupedPoints, id: \.0) { (dateLabel, sessions) in
                Section(header: Text(dateLabel)) {
                    ForEach(sessions, id: \.0) { (sessionLabel, sessionPoints) in
                        Section(header: Text(sessionLabel)) {
                            ForEach(sessionPoints) { point in
                                VStack(alignment: .leading) {
                                    Text("Lat: \(point.coordinate.latitude), Lon: \(point.coordinate.longitude)")
                                    Text("Alt: \(Int(point.altitude)) ft")
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
        }
    }

    private var groupedPoints: [(String, [(String, [LiftPoint])])] {
        let groupedByDate = Dictionary(grouping: points) { point in
            Calendar.current.startOfDay(for: point.timestamp)
        }

        let sortedDates = groupedByDate.keys.sorted(by: >)

        return sortedDates.map { date in
            let dateLabel: String
            if Calendar.current.isDateInToday(date) {
                dateLabel = "Today"
            } else if Calendar.current.isDateInYesterday(date) {
                dateLabel = "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                dateLabel = formatter.string(from: date)
            }

            // Group by sessionID and sort descending by latest timestamp
            let sessions = Dictionary(grouping: groupedByDate[date] ?? []) { $0.sessionID ?? UUID() }
            let sortedSessions = sessions.sorted {
                ($0.value.map { $0.timestamp }.max() ?? .distantPast) >
                ($1.value.map { $0.timestamp }.max() ?? .distantPast)
            }

            let totalSessions = sortedSessions.count

            let labeledSessions: [(String, [LiftPoint])] = sortedSessions.enumerated().map { index, pair in
                let label = "Session \(totalSessions - index)"
                return (label, pair.value.sorted { $0.timestamp > $1.timestamp })
            }

            return (dateLabel, labeledSessions)
        }
    }
}
