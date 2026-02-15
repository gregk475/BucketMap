import SwiftUI
import MapKit
import SwiftData
import CoreLocation

struct ContentView: View {
    // Database access
    @Environment(\.modelContext) private var modelContext
    @Query private var locations: [BucketLocation]
    
    // State for navigation and selection
    @State private var selectedLocation: BucketLocation?
    @State private var showingAddSheet = false
    @State private var showingListSheet = false
    
    // Intro/Splash State
    @State private var showIntro = true
    @State private var introOpacity = 1.0
    
    // Flight Search (Gray Flag) State
    @State private var showingFlightAlert = false
    @State private var flightAddress = ""
    @State private var flightLocation: CLLocationCoordinate2D?
    
    // Initial Camera Position (US Overview)
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
                    Annotation("", coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(location.isVisited ? .green : .red)
                            .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 1)
                            .padding(12)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedLocation = location
                            }
                    }
                }
                
                if let flightCoord = flightLocation {
                    Annotation("Destination", coordinate: flightCoord) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.gray)
                            .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 1)
                    }
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .mapControls {
                MapCompass()
            }

            // 2. UI Overlay (Buttons)
            VStack {
                HStack {
                    Button { showingAddSheet.toggle() } label: {
                        ControlIcon(icon: "plus")
                    }
                    
                    Spacer()
                    
                    Button { showingFlightAlert.toggle() } label: {
                        ControlIcon(icon: "airplane")
                    }
                }
                
                Spacer()
                
                HStack(alignment: .bottom) {
                    Button { showingListSheet.toggle() } label: {
                        ControlIcon(icon: "list.bullet")
                    }
                    
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
                    } label: {
                        ControlIcon(icon: "map.fill")
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            .opacity(showIntro ? 0 : 1)

            // 3. The Intro Layer
            if showIntro {
                ZStack {
                    Color.black.opacity(0.3 * introOpacity)
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                            .frame(height: UIScreen.main.bounds.height * 0.15)
                        
                        Text("BucketMap")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                            .opacity(introOpacity)
                        
                        Spacer()
                    }
                }
                .onAppear {
                    withAnimation(.easeOut(duration: 4.0)) {
                        introOpacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        showIntro = false
                    }
                }
            }
        }
        .alert("Enter Destination", isPresented: $showingFlightAlert) {
            TextField("Address or City", text: $flightAddress)
            Button("Search", action: performFlightSearch)
            Button("Cancel", role: .cancel) { flightAddress = "" }
        } message: {
            EmptyView()
        }
        .sheet(isPresented: $showingAddSheet) {
            AddLocationView()
        }
        .sheet(isPresented: $showingListSheet) {
            LocationListView()
        }
        .sheet(item: $selectedLocation) { location in
            NavigationStack {
                LocationDetailView(location: location)
            }
            .presentationDetents([.medium, .large])
        }
    }
    
    func performFlightSearch() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(flightAddress) { placemarks, error in
            if let coordinate = placemarks?.first?.location?.coordinate {
                let region = MKCoordinateRegion(
                    center: coordinate,
                    latitudinalMeters: 160934,
                    longitudinalMeters: 160934
                )
                
                withAnimation(.easeInOut(duration: 1.5)) {
                    self.flightLocation = coordinate
                    self.position = .region(region)
                }
            }
            flightAddress = ""
        }
    }
}

// Reusable Circular Icon Component - UPDATED SIZE
struct ControlIcon: View {
    let icon: String
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 15).bold()) // Scaled down icon
            .foregroundStyle(.primary)
            .frame(width: 37, height: 37) // 33% smaller (55 -> 37)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
    }
}
