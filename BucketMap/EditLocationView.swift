import SwiftUI
import SwiftData
import CoreLocation

struct EditLocationView: View {
    @Bindable var location: BucketLocation
    @Environment(\.dismiss) private var dismiss
    @State private var isGeocoding = false

    var body: some View {
        Form {
            Section("Location Details") {
                TextField("Title", text: $location.title)
                TextField("Street Address", text: $location.streetAddress)
                
                if !location.streetAddress.isEmpty {
                    Button { updateCoordinates() } label: {
                        Label(isGeocoding ? "Locating..." : "Update Map Pin", systemImage: "mappin.and.ellipse")
                            .font(.caption)
                    }
                    .disabled(isGeocoding)
                }
            }
            
            Section("Notes & Links") {
                TextField("URL", text: $location.urlString)
                TextEditor(text: $location.notes)
                    .frame(minHeight: 100)
            }
            
            Section("Status") {
                Toggle("Visited", isOn: $location.isVisited.animation())
                    .onChange(of: location.isVisited) { _, newValue in
                        location.dateVisited = newValue ? .now : nil
                    }
                
                if location.isVisited {
                    DatePicker("Date", selection: Binding(get: { location.dateVisited ?? .now }, set: { location.dateVisited = $0 }), displayedComponents: .date)
                }
            }
        }
        .navigationTitle("Edit Location")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { dismiss() }
            }
        }
    }

    func updateCoordinates() {
        isGeocoding = true
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location.streetAddress) { placemarks, _ in
            if let coordinate = placemarks?.first?.location?.coordinate {
                location.latitude = coordinate.latitude
                location.longitude = coordinate.longitude
            }
            isGeocoding = false
        }
    }
}
