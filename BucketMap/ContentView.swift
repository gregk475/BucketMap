//
//  ContentView.swift
//  BucketMap
//
//  Created by Greg Kapp on 2/15/26.
//

import SwiftUI
import MapKit
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var locations: [BucketLocation]
    
    // Default view centered on the US
    @State private var position: MapCameraPosition = .automatic
    @State private var showingAddSheet = false
    @State private var showingListSheet = false

    var body: some View {
        ZStack {
            // The Map
            Map(position: $position) {
                ForEach(locations) { location in
                    Annotation(location.title, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                        Image(systemName: "flag.fill")
                            .foregroundStyle(location.isVisited ? .green : .red)
                            .background(.white)
                            .clipShape(Circle())
                    }
                }
            }
            .mapStyle(.standard)
            
            // Overlay Buttons
            VStack {
                HStack {
                    Button {
                        showingAddSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                Spacer()
                HStack {
                    Button {
                        showingListSheet.toggle()
                    } label: {
                        Image(systemName: "list.bullet")
                            .font(.title2)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingAddSheet) {
            AddLocationView()
        }
        .sheet(isPresented: $showingListSheet) {
            LocationListView()
        }
    }
}
