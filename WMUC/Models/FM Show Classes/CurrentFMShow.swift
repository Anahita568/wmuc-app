//
//  CurrentFMShow.swift
//  Radio practice
//
//  Created by Akash B on 6/10/23.
//

import Foundation

class CurrentFMShow: CurrentShow, ObservableObject, InternetManagerShowDelegate {
    var title: String? = nil // The show title
    var djs: [String]? = nil // List of DJ names (can be one or more than one)
    var photoURL: URL? = nil // Image (if it exists)
    var startTime: Date? = nil // Show start time
    var endTime: Date? = nil // Show end time
    
    @Published var isActive: Bool = false // Whether a show is playing
    @Published var isLoading: Bool = true // Whether the class is fetching data from the internet
    
    // TODO: NOT SURE IF THIS IS NECESSARY...
    @Published var showID: Int? // The show's ID. When this value changes, the UI updates ALL of its fields
    
//    init(manager: InternetManager) {
//        refreshData()
//        manager.connectFMShow(self)
//    }
    
    init() {
        // Connects the manager to this class, which is intended to convey information for the UI
        Task {
            /* Asynchronously starts the data fetching process */
            await self.refreshData()
        }
        
        /* Filler data */
        title = "title"
        djs = ["dj name"]
        photoURL = URL(string: "https://wmuc.umd.edu")
        startTime = Date.now
        endTime = Date.now
        showID = nil
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
        // TODO: Add something about the show ID
    }
    
    func updateLoadingState(withValue newLoadingState: Bool) {
        isLoading = newLoadingState
    }
    
    func handleError(errorString: String) {
        // TODO: Handle error
        print(errorString)
        
        /* Change loading state */
        updateLoadingState(withValue: false)
    }
    
    func setData(_ data: CurrentShowPayload) {
        title = data.title
        photoURL = data.image
        
        let dateFormatter = ISO8601DateFormatter()
        startTime = dateFormatter.date(from: data.start)
        endTime = dateFormatter.date(from: data.end)
        
        showID = data.id
        
        isActive = true
        
        updateLoadingState(withValue: false)
        // TODO: Do something with data
    }
    
    func setToInactive() {
        print("Inactive!")
        isActive = false
        
        updateLoadingState(withValue: false)
    }
    
    @MainActor
    func updateCurrentShowFrom(payload: CurrentShowPayload) {
        
        title = payload.title
        djs = [""] // TODO: Change later
        photoURL = payload.image
        
        do {
            startTime = try DateFormatter.formatFromISO8601(payload.start)
            endTime = try DateFormatter.formatFromISO8601(payload.end)
        } catch {
            print("error decoding iso8601 in updateCurrentShowFrom(payload:) for FM")
        }
        
        isActive = true
        isLoading = false
        
        print("updated current show!")
        print(title)
    }
    
    // Makes current show status inactive
    @MainActor
    func makeCurrentShowInactive() {
        isActive = false
        isLoading = false
    }
}
