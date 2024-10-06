//
//  DJActor.swift
//  Radio practice
//
//  Created by Akash Balenalli on 2/20/24.
//

import Foundation

/* The DJActor actor does not correspond to an @ObservableObject View Model, like the other actors. It simply collects DJ information from the WMUC server and caches it for use across the app. */
actor DJActor {
    var loadingState: InternetState = .waiting
    
}
