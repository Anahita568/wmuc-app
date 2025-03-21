//
//  CurrentDigitalShow.swift
//  WMUC
//
//  Created by Anahita on 10/18/24.
//
import Foundation

class CurrentDigitalShow: CurrentShow, ObservableObject, InternetManagerShowDelegate {
    var title: String? = nil // The show title
    var djs: [String]? = nil // List of DJ names (can be one or more than one)
    var photoURL: URL? = nil // Image (if it exists)
    var startTime: Date? = nil // Show start time
    var endTime: Date? = nil // Show end time
    
    @Published var isActive: Bool = false // Whether a show is playing
    @Published var isLoading: Bool = true // Whether the class is fetching data from the internet
    @Published var showID: Int? // The show's ID. When this value changes, the UI updates ALL of its fields
    
    // Initializer
    init() {
        Task {
            /* Asynchronously starts the data fetching process */
            await self.refreshData()
        }
        
        /* Filler data */
        title = "Not live"
        djs = ["--"]
        photoURL = URL(string: "https://wmuc.umd.edu")
        startTime = Date.now
        endTime = Date.now
        showID = nil
    }
    
    // Handles data fetching
    func refreshData() async {
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
        
        // Parse the start and end times
        let dateFormatter = ISO8601DateFormatter()
        startTime = dateFormatter.date(from: data.start)
        endTime = dateFormatter.date(from: data.end)
        
        showID = data.id
        
        isActive = true
        updateLoadingState(withValue: false)
    }
    
    // Set the show to inactive
    func setToInactive() {
        print("No active digital show.")
        isActive = false
        updateLoadingState(withValue: false)
    }
    
    // Updates the current show from a payload received from the server
    @MainActor
    func updateCurrentShowFrom(payload: CurrentShowPayload) {
        title = payload.title
        djs = ["DJ Name"] // TODO: Update with actual DJ names from payload
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
