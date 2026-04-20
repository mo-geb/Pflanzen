# 🌿 Pflanzen

A minimal, native iOS app for keeping your plants alive — built with SwiftUI and SwiftData.

## Features

- **Plant library** — add plants with a name, photo, birthday, and custom watering interval
- **Watering tracker** — track when each plant was last watered and when it's due next
- **Smart push notifications** — automatic daily reminders starting on the due date, with escalating Gen Z messages the longer a plant is overdue
- **Birthday easter egg** — on a plant's birthday, balloons appear on its card and a special push notification fires 🎂
- **Full German localization** — professional UI tone, informal *du*, Gen Z notification vibe

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Persistence | SwiftData |
| Notifications | UserNotifications |
| State | `@Observable` macro |
| Localization | `Localizable.xcstrings` (EN + DE) |

## Project Structure

```
Pflanzen/
├── Model/
│   ├── Plant.swift              # SwiftData model, computed properties (daysUntilDue, isBirthday, age, ageString)
│   └── FrequencyUnit.swift      # Enum: day / week / month with localized display text
├── View/
│   ├── PlantListView.swift      # Main list of all plants
│   ├── PlantCardView.swift      # Card with image, status, water button, birthday overlay
│   ├── PlantDetailView.swift    # Detail / edit view with photo, birthday, watering interval
│   └── SettingsView.swift       # Notification permission management
├── Helper/
│   ├── NotificationManager.swift   # Scheduling watering + birthday push notifications
│   ├── NotificationSettings.swift  # Maps overdue day count → localized message template
│   ├── ImagePicker.swift           # Camera picker wrapper
│   └── PreviewProvider.swift       # Shared ModelContainer + sample data for Xcode previews
└── Resources/
    ├── Localizable.xcstrings    # All UI + notification strings (EN + DE)
    └── Assets.xcassets
```

## Notification System

Notifications are fully developer-controlled — users cannot configure them manually.

### Watering reminders
Scheduled for **15 consecutive days** starting on the plant's next watering date (9:00 AM each day). Messages escalate in urgency:

| Day | Tone |
|---|---|
| 0 | Friendly nudge — due today |
| 1–3 | Slightly concerned |
| 4–6 | Passive-aggressive |
| 7–9 | Full drama mode |
| 10+ | RIP |

### Birthday notification
A **yearly repeating** notification fires at 9:00 AM on the plant's birthday, showing its current age.

Notification identifiers follow the pattern `<uuid>-<dayOffset>` for watering and `<uuid>-birthday` for the birthday reminder, making targeted cancellation straightforward.

## Data Model

```swift
Plant
├── name: String
├── uuid: UUID
├── imageData: Data?          // stored externally via SwiftData
├── frequencyUnit: FrequencyUnit
├── frequencyValue: Int
├── nextWateringDate: Date
├── dateOfBirth: Date
│
├── daysUntilDue: Int         // negative = overdue
├── isOverdue: Bool
├── isBirthday: Bool          // true if today is the plant's birth month+day
├── age: Int                  // full years alive
└── ageString: String         // human-readable age, e.g. "1 year, 3 months"
```

## Requirements

- iOS 17+
- Xcode 15+
