import SwiftUI
import SwiftData

struct LocationListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Fetch all locations, sorted by title
    @Query(sort: \BucketLocation.title) private var locations: [BucketLocation]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(locations) { location in
                    // Tapping a row here opens the EDIT view
                    NavigationLink(destination: EditLocationView(location: location)) {
                        HStack {
                            Image(systemName: "flag.fill")
                                .foregroundStyle(location.isVisited ? .green : .red)
                            
                            VStack(alignment: .leading) {
                                Text(location.title)
                                    .font(.headline)
                                Text(location.streetAddress)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteLocations) // Adds swipe-to-delete
            }
            .navigationTitle("My Bucket List")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton() // Adds the "Edit" mode to delete multiple rows
                }
            }
            .overlay {
                if locations.isEmpty {
                    ContentUnavailableView("No Spots Yet",
                                           systemImage: "map.badge.2d",
                                           description: Text("Add locations from the map to see them here."))
                }
            }
        }
    }
    
    /// Deletes locations from the database
    func deleteLocations(at offsets: IndexSet) {
        for index in offsets {
            let location = locations[index]
            modelContext.delete(location)
        }
    }
}
