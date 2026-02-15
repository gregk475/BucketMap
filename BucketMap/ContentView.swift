import SwiftUI
import MapKit
import SwiftData

struct ContentView: View {
    // Database access
    @Environment(\.modelContext) private var modelContext
    @Query private var locations: [BucketLocation]
    
    // State for navigation and selection
    @State private var selectedLocation: BucketLocation?
    @State private var showingAddSheet = false
    @State private var showingListSheet = false
    
    // Initial Camera Position: Full View of the US
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795),
            span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 60)
        )
    )

    var body: some View {
        ZStack {
            // 1. The Map Layer
            Map(position: $position, selection: $selectedLocation) {
                ForEach(locations) { location in
                    // Empty string "" hides the text label
                    Annotation("", coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 18)) // 33% smaller than standard title size
                            .foregroundStyle(location.isVisited ? .green : .red)
                            .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 1)
                            .onTapGesture {
                                selectedLocation = location
                            }
                    }
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .mapControls {
                MapCompass() // Shows when map is rotated
            }

            // 2. The UI Overlay Layer
            VStack {
                // Top Left: Add Button
                HStack {
                    Button {
                        showingAddSheet.toggle()
                    } label: {
                        ControlIcon(icon: "plus")
                    }
                    Spacer()
                }
                
                Spacer()
                
                // Bottom Row: List and Recenter
                HStack(alignment: .bottom) {
                    Button {
                        showingListSheet.toggle()
                    } label: {
                        ControlIcon(icon: "list.bullet")
                    }
                    
                    Spacer()
                    
                    Button {
                        // Animates back to the full US view
                        withAnimation(.spring()) {
                            position = .region(
                                MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795),
                                    span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 60)
                                )
                            )
                        }
                    } label: {
                        ControlIcon(icon: "map.fill")
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        // Sheets for navigation
        .sheet(isPresented: $showingAddSheet) {
            AddLocationView()
        }
        .sheet(isPresented: $showingListSheet) {
            LocationListView()
        }
        .sheet(item: $selectedLocation) { location in
            NavigationStack {
                EditLocationView(location: location)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

// Reusable Circular Button Component
struct ControlIcon: View {
    let icon: String
    var body: some View {
        Image(systemName: icon)
            .font(.title2.bold())
            .foregroundStyle(.primary)
            .frame(width: 55, height: 55)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
    }
}
