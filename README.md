# Fuel - Car Fueling Tracker

A native iOS app built with SwiftUI and SwiftData to track your vehicle's fuel consumption, costs, and efficiency.

## Features

### 🚗 Multi-Vehicle Support
- Track multiple vehicles
- Each vehicle has its own dashboard and history
- Easy switching between vehicles
- Auto-remembers last viewed vehicle

### 📊 Dashboard
- **Total Spent**: All-time fuel expenses
- **Total Miles**: Distance driven since tracking began
- **Total Gallons**: Fuel consumed
- **Average MPG**: Fuel efficiency (calculated from full fill-ups for accuracy)
- **Average $/Mile**: Cost per mile driven
- **Average Fill-up Cost**: Typical fill-up expense
- **Average $/Gallon**: Average price per gallon across all fill-ups
- **Best/Worst MPG**: Track your fuel efficiency extremes
- **Highest/Lowest Gas Prices**: Track price fluctuations
- **Last Fill-up**: Quick view of most recent fueling
- **Trend Charts**: Visual graphs for MPG, cost, and gas prices over time

### 📝 Fueling Records
- **Date & Time**: When you filled up
- **Odometer Reading**: Current miles (previous miles auto-inferred from prior record)
- **Price per Gallon**: Gas price
- **Gallons**: Amount purchased
- **Total Cost**: What you paid
- **Fill-up Type**: Choose from:
  - **Full Tank**: Normal complete fill-up (MPG calculated normally)
  - **Partial Fill**: Didn't fill completely (affects next record's MPG baseline)
  - **Missed Fueling**: Forgot to record previous fill-up(s) (invalidates this record's MPG)
- **Notes**: Optional memo for each fill-up

### 🧮 Smart Auto-Calculation
Enter any 2 of these 3 fields and the third is calculated automatically:
- Price per Gallon
- Gallons
- Total Cost

### 📈 Post Fill-up Summary
After adding a record, see a beautiful summary showing:
- Gas mileage (MPG) for this fill-up
- Cost per mile
- Trip statistics

### 📤 Import/Export
- **Export to CSV**: Share your data or backup
- **Import from CSV**: Migrate from other apps or spreadsheets
- **Open CSV directly**: Open CSV files from iOS Files app or via Share sheet

### ⚙️ Settings
- View app version and build number
- See data statistics (vehicle count, record count)
- Delete all data option with confirmation

## Requirements

- iOS 17.0+
- Xcode 15.0+

## Installation

1. Open `Fuel.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities (optional, for device testing)
3. Build and run on your device or simulator

## Technical Details

- Built with **SwiftUI** for modern, declarative UI
- Uses **SwiftData** for efficient on-device persistence
- Optimized **statistics caching** for fast dashboard rendering
- Charts optimized for large datasets with automatic bucket averaging

## CSV Format

### Export/Import Format
```csv
date,currentMiles,pricePerGallon,gallons,totalCost,fillUpType,notes
2024-01-15,12500,3.459,10.5,36.32,full,"First fill-up"
```

Fill-up type values: `full`, `partial`, `reset`

Legacy CSV files with boolean `isPartialFillUp` column are still supported for import.

Previous miles are automatically inferred from the prior record's odometer reading.

Supported date formats:
- `yyyy-MM-dd` (preferred)
- `MM/dd/yyyy`
- ISO 8601

## License

MIT License - Feel free to use and modify as needed.
