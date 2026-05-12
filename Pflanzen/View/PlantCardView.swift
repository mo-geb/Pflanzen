import SwiftUI
import SwiftData

struct PlantCardView: View {
    @Bindable var plant: Plant
    @Environment(\.modelContext) private var modelContext
    
    // For hit-testing the water button haptics
    let generator = UINotificationFeedbackGenerator()
    
    @State private var balloonOffset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image or Placeholder
            if let data = plant.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.green.opacity(0.3))
                    .frame(height: 300)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.green.opacity(0.6))
                    )
            }
            
            // Gradient Overlay for text readability
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.8), .clear]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 150)
            
            // Content
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        if plant.isBirthday {
                            Text("🎂")
                                .font(.title2)
                        }
                        Text(plant.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: plant.isOverdue ? "exclamationmark.triangle.fill" : "calendar")
                            .foregroundStyle(plant.isOverdue ? .red : .white.opacity(0.8))
                        
                        Text(statusText)
                            .font(.subheadline)
                            .foregroundStyle(plant.isOverdue ? .red : .white.opacity(0.8))
                            .fontWeight(plant.isOverdue ? .bold : .regular)
                    }
                }
                
                Spacer()
                
                // Water Button
                Button {
                    waterPlant()
                } label: {
                    Image(systemName: plant.shouldFertilizeOnNextWatering ? "flask.fill" : "drop.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .padding()
                        .background(Circle().fill(plant.shouldFertilizeOnNextWatering ? Color.teal : Color.blue))
                        .shadow(radius: 5)
                        .animation(.easeInOut(duration: 0.2), value: plant.shouldFertilizeOnNextWatering)
                }
            }
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .overlay(alignment: .topTrailing) {
            if plant.isBirthday {
                VStack(spacing: -4) {
                    Text("🎈")
                        .font(.system(size: 38))
                        .offset(y: balloonOffset)
                        .animation(
                            .easeInOut(duration: 1.6)
                            .repeatForever(autoreverses: true),
                            value: balloonOffset
                        )
                    Text("🎈")
                        .font(.system(size: 26))
                        .offset(y: -balloonOffset * 0.7)
                        .animation(
                            .easeInOut(duration: 2.1)
                            .repeatForever(autoreverses: true),
                            value: balloonOffset
                        )
                }
                .padding(.top, 12)
                .padding(.trailing, 16)
                .onAppear { balloonOffset = -10 }
            }
        }
    }
    
    private var statusText: String {
        let days = plant.daysUntilDue
        if days == 0 {
            return String(localized: "Due today", comment: "Plant card: watering status when due today")
        } else if days < 0 {
            let overdue = abs(days)
            return overdue == 1
                ? String(localized: "Overdue by 1 day", comment: "Plant card: watering status 1 day overdue")
                : String(localized: "Overdue by \(overdue) days", comment: "Plant card: watering status N days overdue")
        } else {
            return days == 1
                ? String(localized: "Due in 1 day", comment: "Plant card: watering status due in 1 day")
                : String(localized: "Due in \(days) days", comment: "Plant card: watering status due in N days")
        }
    }
    
    private func waterPlant() {
        generator.notificationOccurred(.success)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            plant.waterPlant()
            NotificationManager.shared.scheduleNotifications(for: plant)
            try? modelContext.save()
        }
    }
}

#Preview {
    PlantCardView(plant: PreviewData.overduePlant)
        .withPreviewContainer()
        .padding()
}

