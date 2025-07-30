import SwiftUI

struct LiftCoordinatesView: View {
    let points: [LiftPoint]
    let onPlotSession: ([LiftPoint]) -> Void 
    
    var body: some View {
        List {
            ForEach(groupedPoints, id: \.0) { (dateLabel, sessions) in
                Section(header: Text(dateLabel)) {
                    ForEach(sessions, id: \.0) { (sessionLabel, sessionPoints) in
                        Section(header:
                            HStack {
                                Text(sessionLabel)
                                Spacer()
                                Button("Plot Session") {
                                    onPlotSession(sessionPoints)
                                }
                                .font(.caption)
                            }
                        ) {
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
        let groupedByDate = Dictionary(grouping: points) {
            Calendar.current.startOfDay(for: $0.timestamp)
        }

        let sortedDates = groupedByDate.keys.sorted(by: >)

        return sortedDates.map { date in
            let dateLabel = formattedDate(date)
            let sessions = Dictionary(grouping: groupedByDate[date] ?? []) { $0.sessionID ?? UUID() }

            let sortedSessions = sessions.sorted {
                ($0.value.map(\.timestamp).max() ?? .distantPast) >
                ($1.value.map(\.timestamp).max() ?? .distantPast)
            }

            let total = sortedSessions.count
            let labeledSessions = sortedSessions.enumerated().map { index, pair in
                let label = "Session \(total - index)"
                return (label, pair.value.sorted { $0.timestamp > $1.timestamp })
            }

            return (dateLabel, labeledSessions)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}
