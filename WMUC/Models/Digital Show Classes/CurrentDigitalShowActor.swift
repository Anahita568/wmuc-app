//
//  CurrentDigitalShowActor.swift
//  Radio practice
//
//  Created by Akash Balenalli on 6/2/24.
//

import Foundation

actor CurrentDigitalShowActor {
    var currentShowDetails: CurrentShowPayload?
    var showIsActive: Bool = false
    var loadingState: InternetState = .waiting
    var refreshDate: Date = Date.distantFuture // Done so that the time doesn't get triggered falsely
    let isoFormatter = ISO8601DateFormatter()
}
