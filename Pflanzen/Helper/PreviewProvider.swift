import SwiftUI
import SwiftData

// MARK: - Centralised Preview Helpers

@MainActor
enum PreviewData {

    // MARK: ModelContainer

    /// Shared in-memory container populated with sample plants.
    static let container: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Plant.self, configurations: config)
            for plant in samplePlants {
                container.mainContext.insert(plant)
            }
            return container
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error)")
        }
    }()

    // MARK: Sample Plants

    static let healthyPlant: Plant = {
        let plant = Plant(name: "Monstera", frequencyUnit: .week, frequencyValue: 1)
        plant.nextWateringDate = Calendar.current.date(byAdding: .day, value: 4, to: Date())!
        return plant
    }()

    static let overduePlant: Plant = {
        let plant = Plant(name: "Ficus", frequencyUnit: .day, frequencyValue: 2)
        plant.nextWateringDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        return plant
    }()

    static let samplePlants: [Plant] = [healthyPlant, overduePlant]
}

// MARK: - View Extension

extension View {
    /// Wraps the view with the shared in-memory preview container.
    func withPreviewContainer() -> some View {
        self.modelContainer(PreviewData.container)
    }
}
