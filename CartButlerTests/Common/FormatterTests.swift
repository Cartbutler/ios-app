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
}
