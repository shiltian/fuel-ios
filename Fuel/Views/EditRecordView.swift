import SwiftUI
import SwiftData

struct EditRecordView: View {
    @Bindable var record: FuelingRecord

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Form fields
    @State private var date: Date
    @State private var currentMilesString: String
    @State private var previousMilesString: String
    @State private var pricePerGallonString: String
    @State private var gallonsString: String
    @State private var totalCostString: String
    @State private var isPartialFillUp: Bool
    @State private var notes: String

    @FocusState private var focusedField: EditableField?
    @State private var userEditedFields: [EditableField] = []
    @State private var isCalculating = false

    enum EditableField: Equatable {
        case pricePerGallon
        case gallons
        case totalCost
    }

    init(record: FuelingRecord) {
        self.record = record
        _date = State(initialValue: record.date)
        _currentMilesString = State(initialValue: String(format: "%.0f", record.currentMiles))
        _previousMilesString = State(initialValue: String(format: "%.0f", record.previousMiles))
        _pricePerGallonString = State(initialValue: String(format: "%.3f", record.pricePerGallon))
        _gallonsString = State(initialValue: String(format: "%.2f", record.gallons))
        _totalCostString = State(initialValue: String(format: "%.2f", record.totalCost))
        _isPartialFillUp = State(initialValue: record.isPartialFillUp)
        _notes = State(initialValue: record.notes ?? "")
    }

    // Parsed values
    private var currentMiles: Double? {
        Double(currentMilesString)
    }

    private var previousMiles: Double? {
        Double(previousMilesString)
    }

    private var pricePerGallon: Double? {
        Double(pricePerGallonString)
    }

    private var gallons: Double? {
        Double(gallonsString)
    }

    private var totalCost: Double? {
        Double(totalCostString)
    }

    // Validation
    private var isValid: Bool {
        guard let current = currentMiles, let previous = previousMiles, current > previous else { return false }
        guard let price = pricePerGallon, price > 0 else { return false }
        guard let gal = gallons, gal > 0 else { return false }
        guard let cost = totalCost, cost > 0 else { return false }
        return true
    }

    // Preview MPG
    private var previewMPG: Double? {
        guard let current = currentMiles, let previous = previousMiles, let gal = gallons, gal > 0 else { return nil }
        let miles = current - previous
        return miles / gal
    }

    var body: some View {
        NavigationStack {
            Form {
                // Date Section
                Section {
                    DatePicker("Date & Time", selection: $date, in: ...Date())
                        .font(.custom("Avenir Next", size: 16))
                } header: {
                    Text("When")
                        .font(.custom("Avenir Next", size: 12))
                }

                // Odometer Section
                Section {
                    HStack {
                        Text("Previous Miles")
                            .font(.custom("Avenir Next", size: 16))
                        Spacer()
                        TextField("0", text: $previousMilesString)
                            .font(.custom("Avenir Next", size: 16))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }

                    HStack {
                        Text("Current Miles")
                            .font(.custom("Avenir Next", size: 16))
                        Spacer()
                        TextField("Odometer", text: $currentMilesString)
                            .font(.custom("Avenir Next", size: 16))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }

                    if let current = currentMiles, let previous = previousMiles, current > previous {
                        HStack {
                            Text("Miles This Trip")
                                .font(.custom("Avenir Next", size: 16))
                                .foregroundColor(.teal)
                            Spacer()
                            Text((current - previous).formatted(.number.precision(.fractionLength(0))))
                                .font(.custom("Avenir Next", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(.teal)
                        }
                    }
                } header: {
                    Text("Odometer")
                        .font(.custom("Avenir Next", size: 12))
                }

                // Fuel Section
                Section {
                    HStack {
                        Text("Price per Gallon")
                            .font(.custom("Avenir Next", size: 16))
                        Spacer()
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("0.000", text: $pricePerGallonString)
                            .font(.custom("Avenir Next", size: 16))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .focused($focusedField, equals: .pricePerGallon)
                            .onChange(of: pricePerGallonString) { _, _ in
                                fieldEdited(.pricePerGallon)
                            }
                    }

                    HStack {
                        Text("Gallons")
                            .font(.custom("Avenir Next", size: 16))
                        Spacer()
                        TextField("0.00", text: $gallonsString)
                            .font(.custom("Avenir Next", size: 16))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .focused($focusedField, equals: .gallons)
                            .onChange(of: gallonsString) { _, _ in
                                fieldEdited(.gallons)
                            }
                        Text("gal")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Total Cost")
                            .font(.custom("Avenir Next", size: 16))
                        Spacer()
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $totalCostString)
                            .font(.custom("Avenir Next", size: 16))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .focused($focusedField, equals: .totalCost)
                            .onChange(of: totalCostString) { _, _ in
                                fieldEdited(.totalCost)
                            }
                    }
                } header: {
                    Text("Fuel Details")
                        .font(.custom("Avenir Next", size: 12))
                }

                // Preview Section
                if let mpg = previewMPG {
                    Section {
                        HStack {
                            Image(systemName: "gauge.with.dots.needle.67percent")
                                .foregroundColor(.purple)
                            Text("Estimated MPG")
                                .font(.custom("Avenir Next", size: 16))
                            Spacer()
                            Text("\(mpg.formatted(.number.precision(.fractionLength(1)))) MPG")
                                .font(.custom("Avenir Next", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                        }
                    } header: {
                        Text("Preview")
                            .font(.custom("Avenir Next", size: 12))
                    }
                }

                // Options Section
                Section {
                    Toggle(isOn: $isPartialFillUp) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                            Text("Partial Fill-up")
                                .font(.custom("Avenir Next", size: 16))
                        }
                    }
                }

                // Notes Section
                Section {
                    TextField("Add notes (optional)", text: $notes, axis: .vertical)
                        .font(.custom("Avenir Next", size: 16))
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                        .font(.custom("Avenir Next", size: 12))
                }
            }
            .navigationTitle("Edit Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }

                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            focusedField = nil
                        }
                    }
                }
            }
        }
    }

    private func fieldEdited(_ field: EditableField) {
        // Prevent recursive calls when we programmatically set values
        guard !isCalculating else { return }

        // Track user-edited fields (keep last 2)
        if userEditedFields.last != field {
            userEditedFields.append(field)
            if userEditedFields.count > 2 {
                userEditedFields.removeFirst()
            }
        }

        autoCalculate()
    }

    private func autoCalculate() {
        // Need at least one user-edited field to know what to calculate
        guard !userEditedFields.isEmpty else { return }

        let price = pricePerGallon
        let gal = gallons
        let cost = totalCost

        // Determine which field to calculate (the one not recently edited by user)
        let fieldToCalculate: EditableField
        if userEditedFields.count >= 2 {
            // We have 2 user-edited fields, calculate the third
            let allFields: Set<EditableField> = [.pricePerGallon, .gallons, .totalCost]
            let editedSet = Set(userEditedFields.suffix(2))
            if let remaining = allFields.subtracting(editedSet).first {
                fieldToCalculate = remaining
            } else {
                return
            }
        } else {
            // Only 1 field edited - use default logic based on which fields have values
            if let p = price, p > 0, let g = gal, g > 0, (cost == nil || cost == 0) {
                fieldToCalculate = .totalCost
            } else if let p = price, p > 0, let c = cost, c > 0, (gal == nil || gal == 0) {
                fieldToCalculate = .gallons
            } else if let g = gal, g > 0, let c = cost, c > 0, (price == nil || price == 0) {
                fieldToCalculate = .pricePerGallon
            } else {
                return
            }
        }

        // Perform the calculation
        isCalculating = true
        defer { isCalculating = false }

        switch fieldToCalculate {
        case .totalCost:
            if let p = price, p > 0, let g = gal, g > 0 {
                let calculated = p * g
                totalCostString = String(format: "%.2f", calculated)
            }
        case .gallons:
            if let p = price, p > 0, let c = cost, c > 0 {
                let calculated = c / p
                gallonsString = String(format: "%.2f", calculated)
            }
        case .pricePerGallon:
            if let g = gal, g > 0, let c = cost, c > 0 {
                let calculated = c / g
                pricePerGallonString = String(format: "%.3f", calculated)
            }
        }
    }

    private func saveChanges() {
        guard let current = currentMiles,
              let previous = previousMiles,
              let price = pricePerGallon,
              let gal = gallons,
              let cost = totalCost else { return }

        record.date = date
        record.currentMiles = current
        record.previousMiles = previous
        record.pricePerGallon = price
        record.gallons = gal
        record.totalCost = cost
        record.isPartialFillUp = isPartialFillUp
        record.notes = notes.isEmpty ? nil : notes

        dismiss()
    }
}

#Preview {
    let record = FuelingRecord(
        currentMiles: 1000,
        previousMiles: 800,
        pricePerGallon: 3.459,
        gallons: 12.5,
        totalCost: 43.24
    )

    return EditRecordView(record: record)
        .modelContainer(for: [Vehicle.self, FuelingRecord.self], inMemory: true)
}

