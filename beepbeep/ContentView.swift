import SwiftUI

enum AppSection: String, CaseIterable, Identifiable { //choosing from different secitons
    case map = "Map"
    case saved = "View Saved Points"

    var id: String { rawValue }
}

struct ContentView: View {
    @State private var selection: AppSection? = .map
    @State private var plottedPoints: [LiftPoint] = []

    var body: some View {
        NavigationSplitView { //split view
            List(AppSection.allCases, id: \.self, selection: $selection) { section in
                Text(section.rawValue)
            }
        } detail: {
            switch selection {
            case .map:
                MapView(plottedPoints: $plottedPoints)
            case .saved:
                LiftCoordinatesView(points: LiftCoordinatesStorage.shared.load(),
                                onPlotSession: { sessionPoints in plottedPoints = sessionPoints
                })
    
            default:
                Text("Choose Section")
            }
        }
    }
}
