//
//  Formatter.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-25.
//

import Foundation

enum Formatter {
  static let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter
  }()

  static func currency(with value: Double?) -> String {
    value.flatMap(NSNumber.init).flatMap(currencyFormatter.string) ?? ""
  }

  static func currency(from minPrice: Double?, to maxPrice: Double?) -> String {
    guard let minPrice, let maxPrice else { return "" }
    if minPrice == maxPrice {
      return currency(with: minPrice)
    } else {
      return "\(currency(with: minPrice)) - \(currency(with: maxPrice))"
    }
  }
  
  static func distance(kilometers: Double, locale: Locale = .current) -> String {
    let measurement = Measurement(value: kilometers, unit: UnitLength.kilometers)
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .naturalScale
    formatter.unitStyle = .short
    formatter.locale = locale
    
    // Convert to get the value in the locale's preferred unit
    let localizedSystem = formatter.numberFormatter.locale.measurementSystem
    
    // Handle zero values to use meters/feet instead of mm/inches
    if kilometers == 0 {
      let zeroMeasurement = localizedSystem == .metric
        ? Measurement(value: 0, unit: UnitLength.meters)
        : Measurement(value: 0, unit: UnitLength.feet)
      formatter.unitOptions = .providedUnit
      return formatter.string(from: zeroMeasurement)
    }
    
    let localizedMeasurement = localizedSystem == .metric ? measurement : measurement.converted(to: .miles)
    
    // Set fraction digits based on the localized value
    let numberFormatter = NumberFormatter()
    numberFormatter.maximumFractionDigits = switch localizedMeasurement.value {
      case 1..<10: 1
      default: 0
    }
    numberFormatter.minimumFractionDigits = 0
    formatter.numberFormatter = numberFormatter
    
    return formatter.string(from: measurement)
  }
}
