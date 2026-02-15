import SwiftUI
import MapKit
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var locations: [BucketLocation]
    
    @State private var selectedLocation: BucketLocation?
    @State private var showingAddSheet = false
    @State private var showingListSheet = false
    
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795),
            span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 60)
        )
    )

    var body: some View {
        ZStack {
            // 1. The Map Layer
            Map(position: $position) {
                ForEach(locations) { location in
                    // Using an empty string for the title effectively hides the system label
                    Annotation("", coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 18)) // 33% smaller
                            .foregroundStyle(location.isVisited ? .green : .red)
                            .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 1)
                            .padding(12) // Increases tap target without changing visual size
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedLocation = location
                            }
                    }
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .mapControls {
                MapCompass()
            }

            // 2. UI Overlay
            VStack {
                HStack {
                    Button { showingAddSheet.toggle() } label: { ControlIcon(icon: "plus") }
                    Spacer()
                }
                Spacer()
                HStack(alignment: .bottom) {
                    Button { showingListSheet.toggle() } label: { ControlIcon(icon: "list.bullet") }
                    Spacer()
                    Button {
                        withAnimation(.spring()) {
                            position = .region(
                                MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795),
                                    span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 60)
                                )
                            )
                        }
                    } label: { ControlIcon(icon: "map.fill") }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $showingAddSheet) { AddLocationView() }
        .sheet(isPresented: $showingListSheet) { LocationListView() }
        .sheet(item: $selectedLocation) { location in
            NavigationStack {
                LocationDetailView(location: location)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

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
