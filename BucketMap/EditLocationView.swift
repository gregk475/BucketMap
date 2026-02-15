import SwiftUI
import SwiftData
import CoreLocation

struct EditLocationView: View {
    @Bindable var location: BucketLocation
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var isGeocoding = false

    var body: some View {
        Form {
            Section("Location Details") {
                TextField("Title", text: $location.title)
                
                VStack(alignment: .leading) {
                    TextField("Street Address", text: $location.streetAddress)
                    
                    if !location.streetAddress.isEmpty {
                        Button {
                            updateCoordinates()
                        } label: {
                            Label(isGeocoding ? "Locating..." : "Update Map Pin", systemImage: "mappin.and.ellipse")
                                .font(.caption)
                        }
                        .disabled(isGeocoding)
                        .padding(.top, 4)
                    }
                }
            }
            
            Section("Links & Notes") {
                TextField("URL", text: $location.urlString)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                
                ZStack(alignment: .topLeading) {
                    if location.notes.isEmpty {
                        Text("Add notes here...")
                            .foregroundStyle(.placeholder)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                    TextEditor(text: $location.notes)
                        .frame(minHeight: 100)
                }
            }
            
            Section("Status") {
                Toggle("Visited", isOn: $location.isVisited.animation(.spring()))
                    .onChange(of: location.isVisited) { _, newValue in
                        location.dateVisited = newValue ? .now : nil
                    }
                
                if location.isVisited {
                    DatePicker(
                        "Date Visited",
                        selection: Binding(
                            get: { location.dateVisited ?? .now },
                            set: { location.dateVisited = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .navigationTitle("Edit Spot")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .fontWeight(.bold)
            }
        }
        .overlay {
            if isGeocoding {
                ProgressView()
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    /// Converts the text address into Latitude/Longitude coordinates
    func updateCoordinates() {
        isGeocoding = true
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(location.streetAddress) { placemarks, error in
            if let coordinate = placemarks?.first?.location?.coordinate {
                location.latitude = coordinate.latitude
                location.longitude = coordinate.longitude
            }
            isGeocoding = false
        }
    }
}
