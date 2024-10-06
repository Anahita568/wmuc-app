//
//  CurrentFMShowActor.swift
//  Radio practice
//
//  Created by Akash Balenalli on 2/20/24.
//

import Foundation

actor CurrentFMShowActor {
    var currentShowDetails: CurrentShowPayload?
    var showIsActive: Bool = false // Used to track a show's activity
    var loadingState: InternetState = .waiting
    // TODO: Add setter to refreshDate so that it schedules a timer based on the new value, and maybe deschedules any previous timers created by this actor (since they're not relevant anymore)
    var refreshDate: Date = Date.distantFuture // Done so that the time doesn't get triggered falsely
    let isoFormatter = ISO8601DateFormatter()
    
    // The compiler does not protect asynchronous actor functions from data race conditions; multiple external data structures can call loadData() simulatenously, and they'll all run concurrently. This is why the resolving tasks and using loadingState are necessary. They ensure there will always be at most one ongoing fetch request at a time. The app does this for efficiency since it makes multiple identical, ongoing fetch requests impossible
    func loadData() async {
        /* TODO: Add check to loadingState to make sure simultaneous calls don't do anything: https://developer.apple.com/videos/play/wwdc2021/10133/?time=542 towards the end, might need to make the logic below work through a Task so it resolves when simulatenous calls know previous calls are still loading (go to code example, 11:59 to see what this actually means) */
        
        switch loadingState {
        case .loading(let ongoingTask):
            // Why use result and not value? Value is of type Success and throws an error if the task fails, so it must be handled somehow. It is not necessary to handle the error here, as there is another loadData() that originally initiated this task, which will handle the error (see below)
            print("Awaiting!")
            let _ = await ongoingTask.result
            return // Return out of loadData() once the ongoing task completes
        default: break // If there is no ongoing task from another loadData() call happening right now, continue onwards to start a fetch task
        }
        
        let requestURL = URL(string: "https://wmuc.umd.edu/api/currentShow/FM")
        
        let fetchTask = Task {
            let (responseData, urlResponse) = try await URLSession.shared.data(from: requestURL!)
            
            if let serverResponse = urlResponse as? HTTPURLResponse {
                if serverResponse.statusCode == 204 {
                    // The server returns status 204 when a show isn't playing. This may change in future server releases so this line of code should be monitored closely
                    showIsActive = false
                } else if (400...599).contains(serverResponse.statusCode) {
                    /* Status code is anything between 400 and 599, inclusive. These errors should never occur unless something is wrong with the server, as the request URL & parameters are constant. */
                    loadingState = .error
                } else if serverResponse.statusCode == 200 {
                    /* Request executed successfully...note that as of development, the Express server endpoint that provides live show data does not explicitly send a status code, but it's 200 by default, so this statement should execute safely. This may change if the server code changes to a different library or Express default behavior changes in future versions */
                    
                    /* Convert JSON response into CurrentShowPayload struct */
                    let response = try JSONDecoder().decode(CurrentShowPayload.self, from: responseData)
                    
                    if let formattedDate = isoFormatter.date(from: response.end) {
                        refreshDate = formattedDate
                    } else {
                        throw InternetError.dateFormatFailure("Failed to format FM ISO 8601 string \(response.end) to date")
                    }
                    
                    /* Updates actor with value */
                    currentShowDetails = response
                    
                    showIsActive = true
                    
                    loadingState = .waiting
                }
            }
        }
        
        loadingState = .loading(fetchTask)
        
        do {
            try await fetchTask.value
        } catch { /* NOTE: error can be accessed within catch statements without explicit declaration */
            
            // TODO: Remove call below
            print(String(describing: error))
            
            /* Updates loading state so future calls to get show data work */
            loadingState = .error
        }
        
        print(currentShowDetails)
        
        // TODO: Set earliestDateWhenFMStale
    }
}


