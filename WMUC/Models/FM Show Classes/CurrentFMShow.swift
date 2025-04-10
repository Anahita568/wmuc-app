//
//  CurrentFMShow.swift
//  Radio practice
//
//  Created by Akash B on 6/10/23.
//


import Foundation
import Combine

class CurrentFMShow: CurrentShow, ObservableObject, InternetManagerShowDelegate {
    @Published var title: String? = nil      // The show title
    @Published var djs: [String]? = nil        // List of DJ names (can be one or more than one)
    @Published var photoURL: URL? = nil        // Image (if it exists)
    @Published var startTime: Date? = nil      // Show start time
    @Published var endTime: Date? = nil        // Show end time
    
    @Published var isActive: Bool = false      // Whether a show is playing
    @Published var isLoading: Bool = true      // Whether data is being fetched
    
    @Published var showID: Int? = nil          // The show's ID
    
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
        
        // Filler data for initial display
        title = "filler" // Default fallback title
        djs = ["--"]
        photoURL = nil      // Use nil so that fallback ("notLive") is shown in the UI
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
        await InternetManager.loadFMShowData(for: self)
    }
    
    func showDidUpdate(withTitle title: String, djs: [String], photoURL: String, startTime: Date, endTime: Date) {
        self.title = title
        self.djs = djs
        // self.photoURL = photoURL
        self.startTime = startTime
        self.endTime = endTime
    }
    
    func updateLoadingState(withValue newLoadingState: Bool) {
        isLoading = newLoadingState
    }
    
    func handleError(errorString: String) {
        print("Error: \(errorString)")
        updateLoadingState(withValue: false)
    }
    
    func setData(_ data: CurrentShowPayload) {
        title = data.title
        photoURL = data.image
        
        //parse start and end dates
        let dateFormatter = ISO8601DateFormatter()
        startTime = dateFormatter.date(from: data.start)
        endTime = dateFormatter.date(from: data.end)
        
        showID = data.id
        isActive = true
        updateLoadingState(withValue: false)
    }
    
    //Updates show's properies
    @MainActor
    func updateCurrentShowFrom(payload: CurrentShowPayload) {
        title = payload.title
        djs = ["DJ Name"] // TODO: Change later
        photoURL = payload.image
        
        do {
            startTime = try DateFormatter.formatFromISO8601(payload.start)
            endTime = try DateFormatter.formatFromISO8601(payload.end)
        } catch {
            print("Error decoding ISO8601 in updateCurrentShowFrom(payload:) for FM")
        }
        
        isActive = true
        isLoading = false
        
        print("Updated current show!")
        print(title ?? "No Title")
    }
    
    // Makes current show status inactive
    @MainActor
    func makeCurrentShowInactive() {
        isActive = false
        isLoading = false
    }
    
    // MARK: - InternetManagerShowDelegate Implementation
    
    // Used to notify that no show is currently playing
    func setToInactive() {
        print("Inactive!")
        isActive = false
        updateLoadingState(withValue: false)
    }
}
