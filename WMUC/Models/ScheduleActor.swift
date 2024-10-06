//
//  ScheduleActor.swift
//  Radio practice
//
//  Created by Akash Balenalli on 2/23/24.
//

import Foundation

/* The ScheduleActor handles internet requests to retrieve schedule data. The actor manages synchronization across the app to ensure that calls to the same endpoint are only done when a) a  request to the server is not currently ongoing, and b) cached data is not available. The actor manages the cache, but it DOES NOT track times or determine when the cache should be refreshed. This is the job of the InternetManager static class, which serves as the logic center for the app. */
actor ScheduleActor {
    
}
