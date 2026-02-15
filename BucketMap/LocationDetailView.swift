import SwiftUI
import MapKit

struct LocationDetailView: View {
    let location: BucketLocation
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(location.title)
                        .font(.title.bold())
                    Text(location.streetAddress)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            if !location.notes.isEmpty {
                Section("Notes") { Text(location.notes) }
            }
            
            if !location.urlString.isEmpty {
                Section("Link") {
                    if let url = URL(string: location.urlString) {
                        Link(destination: url) {
                            Label("Open Website", systemImage: "link")
                        }
                    }
                }
            }
            
            Section("Status") {
                HStack {
                    Label(location.isVisited ? "Visited" : "Wishlist",
                          systemImage: location.isVisited ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(location.isVisited ? .green : .secondary)
                    Spacer()
                    if let date = location.dateVisited {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Button { openInMaps() } label: {
                Label("Get Directions", systemImage: "map")
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Done") { dismiss() }
            }
        }
    }
    
    func openInMaps() {
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)))
        destination.name = location.title
        destination.openInMaps()
    }
}
