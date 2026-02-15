//
//  AddLocationView.swift
//  BucketMap
//
//  Created by Greg Kapp on 2/15/26.
//


import SwiftUI
import SwiftData
import CoreLocation

struct AddLocationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Form Fields
    @State private var title = ""
    @State private var address = ""
    @State private var urlString = ""
    @State private var notes = ""
    @State private var isVisited = false
    @State private var dateVisited: Date? = nil
    
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Title (e.g., Grand Canyon)", text: $title)
                    TextField("Street Address", text: $address)
                }
                
                Section("Details") {
                    TextField("URL", text: $urlString)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
                
                Section {
                    Toggle("Visited?", isOn: $isVisited.animation(.spring()))
                    
                    // Only show if the toggle is ON
                    if isVisited {
                        DatePicker(
                            "Date Visited",
                            selection: Binding(
                                get: { dateVisited ?? .now },
                                set: { dateVisited = $0 }
                            ),
                            displayedComponents: .date
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .navigationTitle("New Bucket Spot")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveLocation()
                    }
                    .disabled(title.isEmpty || address.isEmpty || isSaving)
                }
            }
            .overlay {
                if isSaving {
                    ProgressView("Finding coordinates...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            }
        }
    }

    // This is the "Magic" function
    func saveLocation() {
        isSaving = true
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let coordinate = placemarks?.first?.location?.coordinate {
                let newLocation = BucketLocation(
                    title: title,
                    streetAddress: address,
                    urlString: urlString,
                    notes: notes,
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
                
                newLocation.isVisited = isVisited
                if isVisited { newLocation.dateVisited = .now }
                
                modelContext.insert(newLocation)
                dismiss()
            } else {
                // If address isn't found, we'll just stop saving
                isSaving = false
                print("Could not find address")
            }
        }
    }
}
