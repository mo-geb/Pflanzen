import SwiftUI
import SwiftData

struct PlantListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Plant.nextWateringDate) private var plants: [Plant]
    @State private var showingAddPlant = false
    @State private var showingSettings = false
    @State private var selectedPlant: Plant?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if plants.isEmpty {
                        ContentUnavailableView("No Plants", systemImage: "leaf", description: Text("Add your first plant."))
                            .padding(.top, 40)
                    } else {
                        ForEach(plants) { plant in
                            Button {
                                selectedPlant = plant
                            } label: {
                                PlantCardView(plant: plant)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("My Plants")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddPlant = true }) {
                        Label("Add Plant", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingAddPlant) {
                NavigationStack {
                    PlantDetailView(plant: nil)
                }
            }
            .sheet(isPresented: $showingSettings) {
                NavigationStack {
                    SettingsView()
                }
            }
            .sheet(item: $selectedPlant) { plant in
                NavigationStack {
                    PlantDetailView(plant: plant)
                }
            }
            .onAppear {
                NotificationManager.shared.requestPermission()
            }
        }
    }
}

#Preview {
    PlantListView()
        .withPreviewContainer()
}

