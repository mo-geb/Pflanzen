import Foundation
import SwiftData
import SwiftUI

@Model
final class Plant: Identifiable {
    var name: String = ""
    var uuid: UUID = UUID()
    @Attribute(.externalStorage) var imageData: Data?
    
    var frequencyUnit: FrequencyUnit = FrequencyUnit.week
    var frequencyValue: Int = 1
    
    var nextWateringDate: Date = Date()
    var dateOfBirth: Date = Date()
    
    init(name: String, imageData: Data? = nil, frequencyUnit: FrequencyUnit = .week, frequencyValue: Int = 1, dateOfBirth: Date = Date()) {
        self.name = name
        self.imageData = imageData
        self.frequencyUnit = frequencyUnit
        self.frequencyValue = frequencyValue
        self.dateOfBirth = dateOfBirth
        self.nextWateringDate = Plant.calculateNextDate(from: Date(), unit: frequencyUnit, value: frequencyValue)
    }
    
    func waterPlant() {
        self.nextWateringDate = Plant.calculateNextDate(from: Date(), unit: self.frequencyUnit, value: self.frequencyValue)
    }
    
    static func calculateNextDate(from date: Date, unit: FrequencyUnit, value: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        
        switch unit {
        case .day: components.day = value
        case .week: components.day = value * 7 // weeks are tricky in date byAdding sometimes, days are safer
        case .month: components.month = value
        }
        
        return calendar.date(byAdding: components, to: date) ?? date
    }
    
    var daysUntilDue: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfDueDate = calendar.startOfDay(for: nextWateringDate)
        
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfDueDate)
        return components.day ?? 0
    }
    
    var isOverdue: Bool {
        daysUntilDue < 0
    }
    
    var isBirthday: Bool {
        let calendar = Calendar.current
        let today = calendar.dateComponents([.month, .day], from: Date())
        let birth = calendar.dateComponents([.month, .day], from: dateOfBirth)
        return today.month == birth.month && today.day == birth.day
    }
    
    /// Full years the plant has been alive
    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }
    
    var ageString: String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.startOfDay(for: dateOfBirth), to: Calendar.current.startOfDay(for: Date()))
        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0
        
        var parts: [String] = []
        if years > 0 {
            parts.append(years == 1
                ? String(localized: "1 year", comment: "Plant age: singular year")
                : String(localized: "\(years) years", comment: "Plant age: plural years"))
        }
        if months > 0 {
            parts.append(months == 1
                ? String(localized: "1 month", comment: "Plant age: singular month")
                : String(localized: "\(months) months", comment: "Plant age: plural months"))
        }
        if days > 0 || (years == 0 && months == 0) {
            let d = max(0, days)
            parts.append(d == 1
                ? String(localized: "1 day", comment: "Plant age: singular day")
                : String(localized: "\(d) days", comment: "Plant age: plural days"))
        }
        
        return parts.joined(separator: ", ")
    }
}
