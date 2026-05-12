import Foundation
import Observation
import UserNotifications

@MainActor
@Observable
class NotificationManager {
    static let shared = NotificationManager()
    
    var hasPermission = false
    
    init() {
        checkPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.hasPermission = granted
            }
        }
    }
    
    func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleNotifications(for plant: Plant) {
        // Clear existing notifications for this plant
        clearNotifications(for: plant)
        
        guard hasPermission else { return }
        
        // Schedule next 15 days of reminders starting from nextWateringDate
        let calendar = Calendar.current
        let startOfDueDate = calendar.startOfDay(for: plant.nextWateringDate)
        
        for dayOffset in 0...14 {
            // Give it a fixed time, e.g., 9:00 AM
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: startOfDueDate)
            dateComponents.day! += dayOffset
            dateComponents.hour = 9
            dateComponents.minute = 0
            
            // Only schedule if it's in the future
            if let scheduledDate = calendar.date(from: dateComponents), scheduledDate > Date() {
                // Düngen: nur am exakten Gieß-Tag (dayOffset == 0)
                let shouldFertilize = dayOffset == 0 && plant.shouldFertilizeOnNextWatering
                scheduleNotification(for: plant, at: dateComponents, overdueDays: dayOffset, includeFertilize: shouldFertilize)
            }
        }
        
        // Schedule the yearly birthday notification
        scheduleBirthdayNotification(for: plant)
    }
    
    private func scheduleNotification(for plant: Plant, at components: DateComponents, overdueDays: Int, includeFertilize: Bool = false) {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification.title", defaultValue: "hydration check 💧", comment: "Push notification title for plant watering reminders")
        var body = NotificationSettings.shared.messageFor(overdueDays: overdueDays, plantName: plant.name)
        if includeFertilize {
            body += " " + String(localized: "notification.fertilize.hint", defaultValue: "also time to fertilize! 🌿", comment: "Appended to notification when fertilizing is due")
        }
        content.body = body
        content.sound = .default
        
        let id = "\(plant.uuid.uuidString)-\(overdueDays)"
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func clearNotifications(for plant: Plant) {
        // Watering reminders: suffix "-0" to "-14"
        let wateringIds = (0...14).map { "\(plant.uuid.uuidString)-\($0)" }
        // Birthday notification: suffix "-birthday"
        let allIds = wateringIds + ["\(plant.uuid.uuidString)-birthday"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: allIds)
    }
    
    private func scheduleBirthdayNotification(for plant: Plant) {
        let calendar = Calendar.current
        let birthComponents = calendar.dateComponents([.month, .day], from: plant.dateOfBirth)
        
        var trigger = DateComponents()
        trigger.month = birthComponents.month
        trigger.day = birthComponents.day
        trigger.hour = 9
        trigger.minute = 0
        
        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification.birthday.title", defaultValue: "happy birthday 🎂", comment: "Push notification title for plant birthday")
        content.body = String(format: String(localized: "notification.birthday.message", defaultValue: "today %@ turns %lld! give them some extra love 🎈", comment: "Push notification body for plant birthday"), plant.name, plant.age)
        content.sound = .default
        
        let id = "\(plant.uuid.uuidString)-birthday"
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling birthday notification: \(error)")
            }
        }
    }
}
