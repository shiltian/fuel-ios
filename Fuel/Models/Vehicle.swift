import Foundation
import SwiftData

@Model
final class Vehicle {
    var id: UUID
    var name: String
    var make: String?
    var model: String?
    var year: Int?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \FuelingRecord.vehicle)
    var fuelingRecords: [FuelingRecord]?

    init(
        id: UUID = UUID(),
        name: String,
        make: String? = nil,
        model: String? = nil,
        year: Int? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.make = make
        self.model = model
        self.year = year
        self.createdAt = createdAt
    }

    var displayName: String {
        if let make = make, let model = model {
            if let year = year {
                return "\(year) \(make) \(model)"
            }
            return "\(make) \(model)"
        }
        return name
    }

    var sortedRecords: [FuelingRecord] {
        (fuelingRecords ?? []).sorted { $0.date > $1.date }
    }

    var lastRecord: FuelingRecord? {
        sortedRecords.first
    }
}

