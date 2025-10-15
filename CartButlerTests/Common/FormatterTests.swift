import Foundation
import Testing

@testable import CartButler

struct FormatterTests {

  @Test
  func currencyWithNilValue() {
    // Given
    let result = Formatter.currency(with: nil)
    // Then
    #expect(result == "")
  }

  @Test
  func currencyWithZeroValue() {
    // Given
    let result = Formatter.currency(with: .zero)
    // Then
    #expect(result == "$0.00")
  }

  @Test
  func currencyWithPositiveValue() {
    // Given
    let result = Formatter.currency(with: 123.45)
    // Then
    #expect(result == "$123.45")
  }

  // MARK: - currency(from:to:) Tests

  @Test
  func currencyFromToWithBothNilValues() {
    // Given
    let result = Formatter.currency(from: nil, to: nil)
    // Then
    #expect(result == "")
  }

  @Test
  func currencyFromToWithOneNilValue() {
    // Given
    let result = Formatter.currency(from: 10, to: nil)
    // Then
    #expect(result == "")
  }

  @Test
  func currencyFromToWithEqualValues() {
    // Given
    let result = Formatter.currency(from: 99.99, to: 99.99)
    // Then
    #expect(result == "$99.99")
  }

  @Test
  func currencyFromToWithDifferentValues() {
    // Given
    let result = Formatter.currency(from: 10, to: 20)
    // Then
    #expect(result == "$10.00 - $20.00")
  }
  
  // MARK: - Distance Tests - Metric (Kilometers)
  
  @Test
  func distanceMetricZeroValue() {
    // Given
    let locale = Locale(identifier: "en_CA") // Canada uses metric
    let result = Formatter.distance(kilometers: 0, locale: locale)
    // Then
    #expect(result == "0m")
  }
  
  @Test
  func distanceMetricSmallValueShowsMeters() {
    // Given
    let locale = Locale(identifier: "en_CA")
    let result = Formatter.distance(kilometers: 0.5, locale: locale)
    // Then
    #expect(result == "500m")
  }
  
  @Test
  func distanceMetricValueUnderOneShowsMeters() {
    // Given
    let locale = Locale(identifier: "en_CA")
    let result = Formatter.distance(kilometers: 0.999, locale: locale)
    // Then
    #expect(result == "999m")
  }
  
  @Test
  func distanceMetricValueExactlyOne() {
    // Given
    let locale = Locale(identifier: "en_CA")
    let result = Formatter.distance(kilometers: 1.0, locale: locale)
    // Then
    #expect(result == "1km") // No decimal at boundary
  }
  
  @Test
  func distanceMetricValueBetweenOneAndTenShowsDecimal() {
    // Given
    let locale = Locale(identifier: "en_CA")
    let result = Formatter.distance(kilometers: 5.7, locale: locale)
    // Then
    #expect(result == "5.7km")
  }
  
  @Test
  func distanceMetricValueAtUpperBoundary() {
    // Given
    let locale = Locale(identifier: "en_CA")
    let result = Formatter.distance(kilometers: 9.9, locale: locale)
    // Then
    #expect(result == "9.9km")
  }
  
  @Test
  func distanceMetricValueOverTenNoDecimal() {
    // Given
    let locale = Locale(identifier: "en_CA")
    let result = Formatter.distance(kilometers: 15.7, locale: locale)
    // Then
    #expect(result == "16km")
  }
  
  @Test
  func distanceMetricLargeValue() {
    // Given
    let locale = Locale(identifier: "en_CA")
    let result = Formatter.distance(kilometers: 100.4, locale: locale)
    // Then
    #expect(result == "100km")
  }
  
  @Test
  func distanceMetricVerySmallValue() {
    // Given
    let locale = Locale(identifier: "en_CA")
    let result = Formatter.distance(kilometers: 0.05, locale: locale)
    // Then
    #expect(result == "50m")
  }
  
  // MARK: - Distance Tests - Imperial (Miles)
  
  @Test
  func distanceImperialZeroValue() {
    // Given
    let locale = Locale(identifier: "en_US")
    let result = Formatter.distance(kilometers: 0, locale: locale)
    // Then
    #expect(result == "0′")
  }
  
  @Test
  func distanceImperialSmallValueShowsYards() {
    // Given
    let locale = Locale(identifier: "en_US")
    let result = Formatter.distance(kilometers: 0.5, locale: locale)
    // Then
    #expect(result == "547yd")
  }
  
  @Test
  func distanceImperialValueUnderOneMile() {
    // Given
    let locale = Locale(identifier: "en_US")
    let result = Formatter.distance(kilometers: 1.5, locale: locale) // ~0.93 miles
    // Then
    #expect(result == "1mi") // Natural scale rounds to 1 mile
  }
  
  @Test
  func distanceImperialValueBetweenOneAndTenShowsDecimal() {
    // Given
    let locale = Locale(identifier: "en_US")
    let result = Formatter.distance(kilometers: 5.7, locale: locale)
    // Then
    #expect(result == "3.5mi") // ~3.54 miles
  }
  
  @Test
  func distanceImperialValueAtLowerBoundary() {
    // Given
    let locale = Locale(identifier: "en_US")
    let result = Formatter.distance(kilometers: 1.61, locale: locale) // ~1 mile
    // Then
    #expect(result == "1mi")
  }
  
  @Test
  func distanceImperialValueAtUpperBoundary() {
    // Given
    let locale = Locale(identifier: "en_US")
    let result = Formatter.distance(kilometers: 16.0, locale: locale) // ~9.94 miles
    // Then
    #expect(result == "9.9mi")
  }
  
  @Test
  func distanceImperialValueOverTenNoDecimal() {
    // Given
    let locale = Locale(identifier: "en_US")
    let result = Formatter.distance(kilometers: 25, locale: locale)
    // Then
    #expect(result == "16mi") // ~15.5 miles rounds to 16
  }
  
  @Test
  func distanceImperialLargeValue() {
    // Given
    let locale = Locale(identifier: "en_US")
    let result = Formatter.distance(kilometers: 100, locale: locale)
    // Then
    #expect(result == "62mi") // ~62.14 miles
  }
  
  @Test
  func distanceImperialVerySmallValue() {
    // Given
    let locale = Locale(identifier: "en_US")
    let result = Formatter.distance(kilometers: 0.1, locale: locale)
    // Then
    #expect(result == "328′") // Natural scale uses feet with ′ symbol
  }
  
  // MARK: - Edge Cases
  
  @Test
  func distanceWithoutLocaleUsesDeviceDefault() {
    // Given
    let result = Formatter.distance(kilometers: 5.5)
    // Then - should return a non-empty string with a unit
    #expect(result.contains("km") || result.contains("mi") || result.contains("m") || result.contains("yd") || result.contains("′"))
  }
  
  @Test
  func distanceMetricBoundaryBetweenMetersAndKilometers() {
    // Given
    let locale = Locale(identifier: "en_CA")
    let resultJustUnder = Formatter.distance(kilometers: 0.999, locale: locale)
    let resultJustOver = Formatter.distance(kilometers: 1.001, locale: locale)
    // Then
    #expect(resultJustUnder == "999m")
    #expect(resultJustOver == "1km") // 1.001 rounds to 1, no decimal
  }
  
  @Test
  func distanceImperialDecimalBoundary() {
    // Given
    let locale = Locale(identifier: "en_US")
    let resultJustUnder = Formatter.distance(kilometers: 16.08, locale: locale) // ~9.99 miles
    let resultJustOver = Formatter.distance(kilometers: 16.1, locale: locale) // ~10.01 miles
    // Then
    #expect(resultJustUnder == "10mi") // Rounds to 10, no decimal
    #expect(resultJustOver == "10mi") // No decimal for >= 10
  }
}
