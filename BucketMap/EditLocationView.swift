//
//  EditLocationView.swift
//  BucketMap
//
//  Created by Greg Kapp on 2/15/26.
//


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
                TextField("Street Address", text: $location.streetAddress)
            }
            
            Section("Links & Notes") {
                TextField("URL", text: $location.urlString)
                TextEditor(text: $location.notes)
                    .frame(minHeight: 100)
            }
            
            Section("Status") {
                Toggle("Visited", isOn: $location.isVisited.animation(.easeInOut))
                    .onChange(of: location.isVisited) { _, newValue in
                        // Set to now if checked, nil if unchecked
                        location.dateVisited = newValue ? .now : nil
                    }
                
                // The conditional field
                if location.isVisited {
                    DatePicker(
                        "Date Visited",
                        selection: Binding(
                            get: { location.dateVisited ?? .now },
                            set: { location.dateVisited = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .transition(.scale(scale: 0.9, anchor: .top).combined(with: .opacity))
                }
            }
            
            Button("Update Coordinates from Address") {
                updateCoordinates()
            }
            .disabled(isGeocoding)
        }
        .navigationTitle("Edit Spot")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if isGeocoding {
                ProgressView("Updating Map...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
        }
    }

    // If they changed the street address, we need to re-find the GPS pin
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
