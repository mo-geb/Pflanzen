import SwiftUI
import SwiftData
import PhotosUI

struct PlantDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var isEditing: Bool = false
    
    @State private var name: String = ""
    @State private var frequencyUnit: FrequencyUnit = .week
    @State private var frequencyValue: Int = 1
    @State private var dateOfBirth: Date = Date()
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    @State private var showFrequencyPicker = false
    @State private var showingDeleteConfirmation = false
    @State private var showImageActionSheet = false
    @State private var showCamera = false
    @State private var showPhotosPicker = false
    @FocusState private var isNameFocused: Bool
    
    var plant: Plant?
    
    let generator = UINotificationFeedbackGenerator()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Picture Section
                if isEditing {
                    pictureSectionEditing
                } else {
                    pictureSectionShowing
                }
                
                // Name Section
                VStack(spacing: 8) {
                    if isEditing {
                        TextField("Plant Name", text: $name)
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.center)
                            .focused($isNameFocused)
                    } else {
                        Text(name.isEmpty ? "Unnamed Plant" : name)
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.center)
                    }
                    
                    if let plant = plant {
                        Text(plant.ageString)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Details Group
                if isEditing {
                    detailsGroupEditing
                } else {
                    detailsGroupShowing
                }
                
                // Action Buttons
                if !isEditing {
                    Button(action: waterPlant) {
                        HStack {
                            Image(systemName: "drop.fill")
                            Text("Water Plant")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal)
                } else if plant != nil {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Plant")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red.opacity(0.15))
                        .cornerRadius(14)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .onTapGesture {
            isNameFocused = false
        }
        .navigationTitle(plant == nil ? "New Plant" : "Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .navigationBarLeading) {
                    if plant != nil {
                        Button("Cancel") {
                            isEditing = false
                            revertChanges()
                        }
                    } else {
                        Button("Cancel", action: { dismiss() })
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: save)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .bold()
                }
            } else {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close", action: { dismiss() })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        isEditing = true
                    }
                }
            }
        }
        .sheet(isPresented: $showFrequencyPicker) {
            frequencyPickerSheet
        }
        .alert("Delete Plant?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deletePlant()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure? This action cannot be undone.")
        }
        .confirmationDialog("Add Photo", isPresented: $showImageActionSheet, titleVisibility: .visible) {
            Button("Camera") {
                showCamera = true
            }
            Button("Photo Library") {
                showPhotosPicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPickerView(selectedImageData: $selectedImageData)
                .ignoresSafeArea()
        }
        .onAppear {
            if let plant = plant {
                name = plant.name
                frequencyUnit = plant.frequencyUnit
                frequencyValue = plant.frequencyValue
                selectedImageData = plant.imageData
                dateOfBirth = plant.dateOfBirth
                isEditing = false
            } else {
                isEditing = true
            }
        }
    }
    
    private func revertChanges() {
        if let plant = plant {
            name = plant.name
            frequencyUnit = plant.frequencyUnit
            frequencyValue = plant.frequencyValue
            selectedImageData = plant.imageData
            dateOfBirth = plant.dateOfBirth
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var pictureSectionShowing: some View {
        if let data = selectedImageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        } else {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 150, height: 150)
                .overlay(
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                )
        }
    }
    
    @ViewBuilder
    private var pictureSectionEditing: some View {
        Button {
            showImageActionSheet = true
        } label: {
            ZStack(alignment: .bottomTrailing) {
                pictureSectionShowing
                
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.title)
                    .offset(x: 10, y: 10)
            }
        }
        .buttonStyle(.plain)
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
    }
    
    @ViewBuilder
    private var detailsGroupShowing: some View {
        VStack(spacing: 0) {
            // Birthday
            HStack {
                Image(systemName: "gift")
                    .foregroundColor(.blue)
                    .frame(width: 30)
                Text("Birthday")
                Spacer()
                Text(dateOfBirth.formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Divider().padding(.leading, 46)
            
            // Interval
            HStack {
                Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                    .foregroundColor(.blue)
                    .frame(width: 30)
                Text("Watering Interval")
                Spacer()
                Text(frequencyUnit.displayText(for: frequencyValue))
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var detailsGroupEditing: some View {
        VStack(spacing: 0) {
            // Birthday
            HStack {
                Image(systemName: "gift")
                    .foregroundColor(.blue)
                    .frame(width: 30)
                DatePicker("Birthday", selection: $dateOfBirth, displayedComponents: .date)
            }
            .padding()
            
            Divider().padding(.leading, 46)
            
            // Interval
            HStack {
                Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                    .foregroundColor(.blue)
                    .frame(width: 30)
                Text("Watering Interval")
                Spacer()
                Button {
                    isNameFocused = false
                    showFrequencyPicker = true
                } label: {
                    Text(frequencyUnit.displayText(for: frequencyValue))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
                .foregroundColor(.primary)
            }
            .padding()
        }
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var frequencyPickerSheet: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 0) {
                    Picker("Value", selection: $frequencyValue) {
                        ForEach(1...100, id: \.self) { val in
                            Text("\(val)").tag(val)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    
                    Picker("Unit", selection: $frequencyUnit) {
                        Text("Days").tag(FrequencyUnit.day)
                        Text("Weeks").tag(FrequencyUnit.week)
                        Text("Months").tag(FrequencyUnit.month)
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Set Interval")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showFrequencyPicker = false }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
    
    // MARK: - Actions
    
    private func waterPlant() {
        guard let plant = plant else { return }
        generator.notificationOccurred(.success)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            plant.waterPlant()
            NotificationManager.shared.scheduleNotifications(for: plant)
            try? modelContext.save()
        }
    }
    
    private func save() {
        if let plant = plant {
            plant.name = name
            plant.frequencyUnit = frequencyUnit
            plant.frequencyValue = max(1, frequencyValue)
            plant.imageData = selectedImageData
            plant.dateOfBirth = dateOfBirth
            
            // Reschedule since interval might have changed
            plant.nextWateringDate = Plant.calculateNextDate(from: Date(), unit: plant.frequencyUnit, value: plant.frequencyValue)
            NotificationManager.shared.scheduleNotifications(for: plant)
            
            isEditing = false
        } else {
            let newPlant = Plant(name: name, imageData: selectedImageData, frequencyUnit: frequencyUnit, frequencyValue: max(1, frequencyValue), dateOfBirth: dateOfBirth)
            modelContext.insert(newPlant)
            NotificationManager.shared.scheduleNotifications(for: newPlant)
            dismiss()
        }
        
        try? modelContext.save()
    }
    
    private func deletePlant() {
        if let plant = plant {
            NotificationManager.shared.clearNotifications(for: plant)
            modelContext.delete(plant)
            try? modelContext.save()
            dismiss()
        }
    }
}

#Preview("Existing Plant") {
    NavigationStack {
        PlantDetailView(plant: PreviewData.healthyPlant)
    }
    .withPreviewContainer()
}

#Preview("New Plant") {
    NavigationStack {
        PlantDetailView(plant: nil)
    }
    .withPreviewContainer()
}

