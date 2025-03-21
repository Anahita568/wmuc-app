//
//  InternetManager.swift
//  Radio practice
//
//  Created by Akash B on 6/10/23.
//

import Foundation

/* TODO: NOTE!!!!
    The following is the LATEST design architecture that this app will be using.
    The InternetManager pays attention to last fetched times and when shows change. When it's deemed necessary to update data, it fetches data from the server and stores them for use in four view models: CurrentFMShow, CurrentDigitalShow, FMWeekSchedule, and DigitalWeekSchedule. These are then accessed by the appropriate views to create user interfaces.
 
    Current show data becomes stale when the last fetched show ends. Schedule data is immediately considered stale when a current show doesn't match what the schedule says should be playing, or if the day is over (since there's only day for the next 7 days' worth of shows, including the current day, data needs to be updated whenever there's a new show). Schedules and current show data should NOT be persisted in long-term memory; if the app is closed and restarted, new data should be fetched again. This is intentional, as users may potentially experience stale data and force quit the app to trigger a refresh. (Stale data is not an intended outcome and should be considered a bug.)
 */

/* The InternetManager handles show changes and instructs other classes to refresh data when necessary. */
struct InternetManager {
    // MARK: - Actors to handle accessing data from the server and caching it
    static private var currentFMShowActor = CurrentFMShowActor()
    static private var currentDigitalShowActor = CurrentDigitalShowActor() // New actor for digital show data
    
    // MARK: - Data to store for current FM show view model
    static private var currentFMShow: CurrentShow?
    static private var fmShowEndDate: Date? // The earliest date at which the data becomes stale again & refresh is needed
    //static private var fmShowViewModel: MediaBarManager? = nil
    static private var earliestDateWhenFMStale: Date? = nil
    
    // MARK: - Data to store for current Digital show view model
    static private var currentDigitalShow: CurrentShow? // To store the current digital show data
    static private var digitalShowEndDate: Date? // The earliest date at which the data becomes stale again & refresh is needed
    static private var digitalLastFetched: Date? // Date when Digital show data was last fetched
    
    // MARK: - Data to store for FM and Digital schedules (Subject to change...)
    // 1. An array of custom structs/classes (probably structs), each of which is an individual show (cover, time it plays, name, description, etc.)
    // 2. Date when the schedule becomes stale again (7 days from fetch date)
    
    // TODO: Is this necessary???
    static private var FMLastFetched: Date? // Date when FM show data was last fetched
    
    // MARK: - Helper Methods for Stale Data Checks
    static func shouldRefreshFMData() -> Bool {
        guard let endDate = fmShowEndDate else { return true }
        return Date() >= endDate
    }

    static func shouldRefreshDigitalData() -> Bool {
        guard let endDate = digitalShowEndDate else { return true }
        return Date() >= endDate
    }
    
    // MARK: - FM Show Data Fetching
    static func loadFMShowData(for show: CurrentFMShow) async {
        print("\(Unmanaged.passUnretained(show).toOpaque())") // Debugging: Print memory address of CurrentFMShow
        
        FMLastFetched = Date.now
        
        // Call the FM actor to load data
        await currentFMShowActor.loadData()
        
        // TODO: Create method in CurrentFMShow that takes an actor and updates its values based on what's in the CurrentFMShowActor's and DJActor's cached data
               if await currentFMShowActor.showIsActive {
                   // currentShowDetails could be nil if there is no active show
                   let currentShowPayload = await currentFMShowActor.currentShowDetails!
                   await show.updateCurrentShowFrom(payload: currentShowPayload)
               } else {
                   await show.makeCurrentShowInactive()
               }
           }


    // MARK: - Digital Show Data Fetching
    //
    static func loadDigitalShowData(for show: CurrentDigitalShow) async {
        digitalLastFetched = Date.now
        
        // Call the Digital actor to load data
        await currentDigitalShowActor.loadData()

                
                if await currentDigitalShowActor.showIsActive {
                    // currentShowDetails could be nil if there is no active show
                    let currentShowPayload = await currentDigitalShowActor.currentShowDetails!
                    await show.updateCurrentShowFrom(payload: currentShowPayload)
                } else {
                    await show.makeCurrentShowInactive()
                }
            }
}

protocol InternetManagerShowDelegate {
    func showDidUpdate(withTitle: String, djs: [String], photoURL: String, startTime: Date, endTime: Date)
    func updateLoadingState(withValue: Bool)
    func handleError(errorString: String)
    func setData(_ data: CurrentShowPayload)
    /* Used to tell the view model (a child of CurrentShow) that there is no show currently playing. */
    func setToInactive()
}




