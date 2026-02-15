import SwiftUI
import SwiftData

struct LocationListView: View {
    // This pulls all locations from the database, sorted by newest first
    @Query(sort: \BucketLocation.dateAdded, order: .reverse) private var locations: [BucketLocation]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""

    // Filter logic for the search bar
    var filteredLocations: [BucketLocation] {
        if searchText.isEmpty {
            return locations
        } else {
            return locations.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredLocations) { location in
                    NavigationLink(destination: EditLocationView(location: location)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(location.title)
                                    .font(.headline)
                                Text(location.streetAddress)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "flag.fill")
                                .foregroundStyle(location.isVisited ? .green : .red)
                        }
                    }
                }
                .onDelete(perform: deleteLocation)
                
            }
            .navigationTitle("Bucket List")
            .searchable(text: $searchText, prompt: "Search spots...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton() // Allows bulk deleting
                }
            }
        }
    }

    private func deleteLocation(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredLocations[index])
        }
    }
}
