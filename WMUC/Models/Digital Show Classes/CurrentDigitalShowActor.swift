//
//  CurrentDigitalShowActor.swift
//  Radio practice
//
//  Created by Akash Balenalli on 6/2/24.
//
import Foundation

actor CurrentDigitalShowActor {
    var currentShowDetails: CurrentShowPayload? = nil // Stores details of the currently playing show
    var showIsActive: Bool = false // Tracks if a show is currently active
    var loadingState: InternetState = .waiting // Tracks the current loading state
    var refreshDate: Date = Date.distantFuture // Used to refresh data at the correct time
    let isoFormatter = ISO8601DateFormatter() // Formatter for parsing dates from API responses
    
    // Data fetching method
    func loadData() async {
        // Check if there's already a loading task to prevent duplicate fetches
        switch loadingState {
        case .loading(let ongoingTask):
            // Wait for the ongoing task to complete, if one exists
            print("Awaiting...")
            let _ = await ongoingTask.result
            return // Exit once the ongoing task completes
        default:
            break // If no task is in progress, proceed with data fetching
        }
        
        // Prepare the request URL
        let requestURL = URL(string: "https://wmuc.umd.edu/api/currentShow/DIG")
        
        // Define the task that fetches data from the server
        let fetchTask = Task {
            // Attempt to fetch data from the server
            let (responseData, urlResponse) = try await URLSession.shared.data(from: requestURL!)
            
            // Cast the response to `HTTPURLResponse` to check status code
            if let serverResponse = urlResponse as? HTTPURLResponse {
                if serverResponse.statusCode == 204 {
                    // Status 204 means no active show
                    showIsActive = false
                } else if (400...599).contains(serverResponse.statusCode) {
                    // Handle client or server errors (status codes between 400 and 599)
                    loadingState = .error
                } else if serverResponse.statusCode == 200 {
                    // Successful response (status code 200)
                    
                    // Decode the JSON response into `CurrentShowPayload`
                    let response = try JSONDecoder().decode(CurrentShowPayload.self, from: responseData)
                    
                    // Parse the end date from the response and update `refreshDate`
                    if let formattedDate = isoFormatter.date(from: response.end) {
                        refreshDate = formattedDate
                    } else {
                        throw InternetError.dateFormatFailure("Failed to format Digital Show ISO 8601 string \(response.end) to date")
                    }
                    
                    // Update the actor state with the fetched data
                    currentShowDetails = response
                    showIsActive = true
                    loadingState = .waiting
                }
            }
        }
        
        // Set the loading state to indicate a fetch is in progress
        loadingState = .loading(fetchTask)
        
        // Wait for the task to complete and handle any potential errors
        do {
            try await fetchTask.value
        } catch {
            print("Error fetching digital show data: \(error)")
            loadingState = .error // Set the loading state to error in case of failure
        }
        
        print(currentShowDetails ?? "No digital show details available")
    }
}
