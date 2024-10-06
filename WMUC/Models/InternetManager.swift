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

/* The internet manager handles show changes and instructs other classes to refresh data when necessary. */
struct InternetManager {
    // MARK: Actors to handle accessing data from the server and caching it
    static private var currentFMShowActor = CurrentFMShowActor()
    
    // MARK: Data to store for current FM show view model
    static private var currentFMShow: CurrentShow?
    static private var fmShowEndDate: Date? // The earliest date at which the data becomes stale again & refresh is needed
    static private var fmShowViewModel: MediaBarManager? = nil
    static private var earliestDateWhenFMStale: Date? = nil
    
    // MARK: Data to store for current Digital show view model
    static private var currentDigitalShow: CurrentShow?
    static private var digitalShowEndDate: Date?
    
    // MARK: Data to store for fm schedule view model
    // Subject to change...
    // 1. An array of custom structs/classes (probably structs), each of which is an individual show (cover, time it plays, name, description etc.)
    // 2. Date when the schedule becomes stale again (7 days from fetch date)
    
    // MARK: Data to store for digital schedule view model
    // Subject to change...
    // 1. An array of custom structs/classes (probably structs), each of which is an individual show (cover, time it plays, name, description, etc.)
    // 2. Date when the schedule becomes stale again (7 days from fetch date)
    
    // TODO: Is this necessary???
    static private var FMLastFetched: Date? // Date when FM show data was last fetched
    
    static func loadFMShowData(for show: CurrentFMShow) async {
        print("\(Unmanaged.passUnretained(show).toOpaque())")
        
        // TODO: (Lower priority) Do something with this
        FMLastFetched = Date.now
        
        // Tells the actor to make the thread-safe call to get data. This call holds the InternetManager up at this point until currentFMShowActor.loadData() concludes
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
    
    // MARK: Linker methods
    static func connectFMShowManager(_ manager: MediaBarManager) {
        fmShowViewModel = manager
        print("Linked!!")
    }
    
    private static func getIndividualShowDJ() {
        
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
