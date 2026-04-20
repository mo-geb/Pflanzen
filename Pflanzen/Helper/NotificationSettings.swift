import Foundation

class NotificationSettings {
    static let shared = NotificationSettings()
    
    private init() {}
    
    func messageFor(overdueDays: Int, plantName: String) -> String {
        let index = min(max(overdueDays, 0), 10)
        let template: String
        switch index {
        case 0:  template = String(localized: "notification.message.day0")
        case 1:  template = String(localized: "notification.message.day1")
        case 2:  template = String(localized: "notification.message.day2")
        case 3:  template = String(localized: "notification.message.day3")
        case 4:  template = String(localized: "notification.message.day4")
        case 5:  template = String(localized: "notification.message.day5")
        case 6:  template = String(localized: "notification.message.day6")
        case 7:  template = String(localized: "notification.message.day7")
        case 8:  template = String(localized: "notification.message.day8")
        case 9:  template = String(localized: "notification.message.day9")
        default: template = String(localized: "notification.message.day10")
        }
        return String(format: template, plantName)
    }
}

