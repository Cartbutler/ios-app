//
//  LocationService.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-16.
//

import CoreLocation
import Foundation

enum LocationError: Error {
  case permissionDenied
  case locationUnavailable
  case permissionRequestFailed
}

@MainActor
protocol LocationServiceProvider {
  func getCurrentLocation() async throws -> CLLocation
}

final class LocationService: NSObject, LocationServiceProvider {

  private let locationManager = CLLocationManager()
  private var locationContinuation: CheckedContinuation<CLLocation, Error>?
  private var permissionContinuation: CheckedContinuation<Void, Error>?

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
  }

  func getCurrentLocation() async throws -> CLLocation {
    switch locationManager.authorizationStatus {
    case .notDetermined:
      try await requestPermission()
      return try await waitForLocation()
    case .authorizedAlways, .authorizedWhenInUse:
      return try await waitForLocation()
    case .restricted, .denied:
      throw LocationError.permissionDenied
    @unknown default:
      throw LocationError.permissionRequestFailed
    }
  }

  private func requestPermission() async throws {
    try await withCheckedThrowingContinuation { continuation in
      permissionContinuation = continuation
      locationManager.requestWhenInUseAuthorization()
    }
  }

  private func waitForLocation() async throws -> CLLocation {
    try await withCheckedThrowingContinuation { continuation in
      locationContinuation = continuation
      locationManager.requestLocation()
    }
  }

  private func handlePermissionChange(_ status: CLAuthorizationStatus) {
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      permissionContinuation?.resume()
    case .denied, .restricted:
      permissionContinuation?.resume(throwing: LocationError.permissionDenied)
    default:
      permissionContinuation?.resume(throwing: LocationError.permissionRequestFailed)
    }
    permissionContinuation = nil
  }

  private func handleLocationUpdate(_ location: CLLocation) {
    locationContinuation?.resume(returning: location)
    locationContinuation = nil
  }

  private func handleLocationError() {
    locationContinuation?.resume(throwing: LocationError.locationUnavailable)
    locationContinuation = nil
  }
}

extension LocationService: CLLocationManagerDelegate {
  nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    let status = manager.authorizationStatus
    Task { @MainActor [weak self] in
      self?.handlePermissionChange(status)
    }
  }

  nonisolated func locationManager(
    _ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]
  ) {
    Task { @MainActor in
      guard let location = locations.last else { return }
      handleLocationUpdate(location)
    }
  }

  nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    Task { @MainActor in
      handleLocationError()
    }
  }
}
