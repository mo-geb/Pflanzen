import Foundation

enum FrequencyUnit: Int16, Codable {
    case day = 1
    case week = 2
    case month = 3
    
    func displayText(for value: Int) -> String {
        switch self {
        case .day:
            return value == 1
                ? String(localized: "Every day", comment: "Watering frequency: every day")
                : String(localized: "Every \(value) days", comment: "Watering frequency: every N days")
        case .week:
            return value == 1
                ? String(localized: "Every week", comment: "Watering frequency: every week")
                : String(localized: "Every \(value) weeks", comment: "Watering frequency: every N weeks")
        case .month:
            return value == 1
                ? String(localized: "Every month", comment: "Watering frequency: every month")
                : String(localized: "Every \(value) months", comment: "Watering frequency: every N months")
        }
    }
}

