import Foundation
import SwiftData

@Model
final class Plant {
    var name: String = ""
    var uuid: UUID = UUID()
    @Attribute(.externalStorage) var imageData: Data?
    
    var frequencyUnit: FrequencyUnit = FrequencyUnit.week
    var frequencyValue: Int = 1
    
    /// Düngen jede N-te Bewässerung. nil = Düngen deaktiviert.
    var fertilizeEveryNthWatering: Int? = nil
    /// Zählt alle bisherigen Bewässerungen (für Dünge-Berechnung).
    var wateringCount: Int = 0
    
    var nextWateringDate: Date = Date()
    var dateOfBirth: Date = Date()
    
    init(name: String, imageData: Data? = nil, frequencyUnit: FrequencyUnit = .week, frequencyValue: Int = 1, fertilizeEveryNthWatering: Int? = nil, dateOfBirth: Date = Date()) {
        self.name = name
        self.imageData = imageData
        self.frequencyUnit = frequencyUnit
        self.frequencyValue = frequencyValue
        self.fertilizeEveryNthWatering = fertilizeEveryNthWatering
        self.dateOfBirth = dateOfBirth
        self.nextWateringDate = Plant.calculateNextDate(from: Date(), unit: frequencyUnit, value: frequencyValue)
    }
    
    func waterPlant() {
        self.wateringCount += 1
        self.nextWateringDate = Plant.calculateNextDate(from: Date(), unit: self.frequencyUnit, value: self.frequencyValue)
    }
    
    /// true wenn beim nächsten Gießen auch gedüngt werden soll.
    var shouldFertilizeOnNextWatering: Bool {
        guard let n = fertilizeEveryNthWatering, n > 0 else { return false }
        // wateringCount ist der Stand *vor* dem nächsten Gießen,
        // d.h. nach dem Gießen wäre er wateringCount+1.
        return (wateringCount + 1) % n == 0
    }
    
    /// true wenn die Pflanze heute (am Gieß-Tag) auch gedüngt werden muss.
    var shouldFertilizeToday: Bool {
        guard let n = fertilizeEveryNthWatering, n > 0 else { return false }
        return wateringCount % n == 0 && wateringCount > 0
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
        guard age >= 1 else { return false }
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
