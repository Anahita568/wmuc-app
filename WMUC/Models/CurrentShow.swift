//
//  CurrentShow.swift
//  Radio practice
//
//  Created by Akash B on 6/10/23.
//

import Foundation

protocol CurrentShow {
    var isActive: Bool { get set }// Whether a show is playing
    var title: String? { get set }// The show title
    var djs: [String]? { get set }// List of DJ names (can be one or more than one)
    var photoURL: URL? { get set } // Image (if it exists)
    var startTime: Date? { get set } // Show start time
    var endTime: Date? { get set } // Show end time
    var isLoading: Bool { get set }
    
    // private var audioURL: String // The URL string to access the audio stream
    
    func refreshData() async // Refreshes data (handled by manager)
}
