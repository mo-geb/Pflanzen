import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) var scenePhase
    private let notificationManager = NotificationManager.shared
    
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                if !notificationManager.hasPermission {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notifications Disabled")
                            .font(.headline)
                            .foregroundStyle(.red)
                        Text("To receive watering reminders, please enable notifications for this app in System Settings.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .padding(.top, 4)
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                    .padding(.vertical, 4)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Automatic Reminders")
                            .font(.headline)
                        Text("Watering reminders for your plants are already set up. You will be notified appropriately when a plant needs to be watered, and the messages will become more urgent if overdue.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Section {
                HStack {
                    Spacer()
                    versionInfo
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onAppear {
            notificationManager.checkPermission()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                notificationManager.checkPermission()
            }
        }
    }
    
    @ViewBuilder
    var versionInfo: some View {
        Text(Bundle.main.fullVersionString)
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }

    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
    }

    var fullVersionString: String {
        "v\(appVersion) (Build \(buildNumber))"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .withPreviewContainer()
}

