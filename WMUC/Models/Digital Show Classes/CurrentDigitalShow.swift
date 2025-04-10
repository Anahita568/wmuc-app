//
//  CurrentDigitalShow.swift
//  WMUC
//
//  Created by Anahita on 10/18/24.
//

import Foundation
import Combine

class CurrentDigitalShow: CurrentShow, ObservableObject, InternetManagerShowDelegate {
    @Published var title: String? = nil           // The show title
    @Published var djs: [String]? = nil             // List of DJ names (can be one or more)
    @Published var photoURL: URL? = nil             // Image (if it exists)
    @Published var startTime: Date? = nil           // Show start time
    @Published var endTime: Date? = nil             // Show end time
    
    @Published var isActive: Bool = false           // Whether a show is playing
    @Published var isLoading: Bool = true           // Whether data is being fetched
    @Published var showID: Int? = nil               // The show's ID
    
    // A cancellable to store the timer subscription
    private var refreshCancellable: AnyCancellable?
    
    init() {
        // Start the initial refresh immediately
        Task {
            await self.refreshData()
        }
        
        // Calculate the time until the next full hour
        let now = Date()
        let calendar = Calendar.current
        // Get the next full hour (e.g., if now is 8:47, next full hour is 9:00)
        guard let nextFullHour = calendar.nextDate(after: now,
                                                     matching: DateComponents(minute: 0, second: 0),
                                                     matchingPolicy: .nextTime) else {
            // Fallback: if calculation fails, start repeating every 3600 seconds
            startRepeatingTimer()
            return
        }
        
        let initialDelay = nextFullHour.timeIntervalSince(now)
        print("Next refresh in \(initialDelay) seconds at \(nextFullHour)")
        
        // Schedule the first refresh to occur at the next full hour.
        DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay) { [weak self] in
            Task {
                await self?.refreshData()
            }
            // Then start a repeating timer every 3600 seconds.
            self?.startRepeatingTimer()
        }
        
        
        // filler data
        title = "Not live"
        djs = ["--"]
        photoURL = URL(string: "https://wmuc.umd.edu")
        startTime = Date.now
        endTime = Date.now
        showID = nil
    }
    private func startRepeatingTimer() {
        refreshCancellable = Timer.publish(every: 3600, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.refreshData()
                }
            }
    }
    
    // Handles data fetching
    func refreshData() async {
        print("Refreshing Digital Show at \(Date())")
        await InternetManager.loadDigitalShowData(for: self)
    }
    
    // Called when the show details are updated with new data
    func showDidUpdate(withTitle title: String, djs: [String], photoURL: String, startTime: Date, endTime: Date) {
        self.title = title
        self.djs = djs
        // self.photoURL = photoURL
        self.startTime = startTime
        self.endTime = endTime
    }
    
    // Updates the loading state
    func updateLoadingState(withValue newLoadingState: Bool) {
        isLoading = newLoadingState
    }
    
    // Handle any errors encountered during data fetching
    func handleError(errorString: String) {
        print("Error: \(errorString)")
        updateLoadingState(withValue: false)
    }
    
    // Set the data when a digital show payload is received
    func setData(_ data: CurrentShowPayload) {
        title = data.title
        photoURL = data.image
        
        // Parse start and end times
        let dateFormatter = ISO8601DateFormatter()
        startTime = dateFormatter.date(from: data.start)
        endTime = dateFormatter.date(from: data.end)
        
        showID = data.id
        isActive = true
        updateLoadingState(withValue: false)
    }
    
    func setToInactive() {
        print("No active digital show.")
        isActive = false
        updateLoadingState(withValue: false)
    }
    
    // Updates the current show from a payload received from the server
    @MainActor
    func updateCurrentShowFrom(payload: CurrentShowPayload) {
        print("Digital Show updated with title: \(payload.title), image: \(payload.image)")
        title = payload.title
        djs = ["DJ Name"] // TODO: Update with actual DJ names from payload.
        photoURL = payload.image
        
        do {
            startTime = try DateFormatter.formatFromISO8601(payload.start)
            endTime = try DateFormatter.formatFromISO8601(payload.end)
        } catch {
            print("Error decoding ISO8601 date for Digital Show.")
        }
        
        isActive = true
        isLoading = false
    }
    
    // Manually make the current show inactive
    @MainActor
    func makeCurrentShowInactive() {
        isActive = false
        isLoading = false
    }
}
