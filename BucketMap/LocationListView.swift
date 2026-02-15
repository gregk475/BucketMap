import SwiftUI
import SwiftData

struct LocationListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \BucketLocation.title) private var locations: [BucketLocation]
    
    // State to trigger the Add sheet from this view
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(locations) { location in
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
                .onDelete(perform: deleteLocations)
            }
            .navigationTitle("My Bucket List")
            .toolbar {
                // Left Side: Edit/Delete mode
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
                // Right Side: Add and Done buttons
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddLocationView()
            }
            .overlay {
                if locations.isEmpty {
                    ContentUnavailableView("No Spots Yet",
                                           systemImage: "map.badge.2d",
                                           description: Text("Add locations to start your journey."))
                }
            }
        }
    }
    
    func deleteLocations(at offsets: IndexSet) {
        for index in offsets {
            let location = locations[index]
            modelContext.delete(location)
        }
    }
}
