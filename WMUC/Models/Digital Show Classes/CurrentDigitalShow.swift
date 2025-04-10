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
        Task {
            await self.refreshData()
        }
        
        // sets up a timer that refreshes the data every hour (3600 seconds)
        refreshCancellable = Timer.publish(every: 3600, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.refreshData()
                }
            }
        
        // filler data
        title = "Not live"
        djs = ["--"]
        photoURL = URL(string: "https://wmuc.umd.edu")
        startTime = Date.now
        endTime = Date.now
        showID = nil
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
