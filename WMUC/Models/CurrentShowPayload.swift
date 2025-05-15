//
//  CurrentShowPayload.swift
//  Radio practice
//
//  Created by Akash Balenalli on 2/20/24.
//

import Foundation

/* This enum is used across all actors in this app to help synchronous functions within actors keep track of loading states. */
enum InternetState {
    case loading(Task<Void, Error>)
    case error
    case waiting /* Means the actor is neither loading nor has it run into an error */
}

/* This struct type allows for easy JSON decoding. The JSON payload for the current show returns
 from the server, after which it's converted an instance of this struct using JSONDecoder(), a
 Swift protocol. The struct instance is then sent to the appropriate class (CurrentFMShow, CurrentDigitalShow), which extracts the data. */
struct CurrentShowPayload: Decodable {
    // : THE NAME AND TYPE OF THESE PROPERTIES MUST BE IDENTICAL TO THE CORRESPONDING JSON VALUE-KEY PAIR IN THE CURRENT SHOW PAYLOAD RETURNED FROM THE SERVER. NOT CHANGE THE NAME OF THESE PROPERTIES UNLESS THE CORRESPONDING KEY NAME CHANGES. IT IS HIGHLY UNLIKELY THAT THE TYPE WILL EVER NEED TO BE CHANGED.
    let start: String
    let end: String
    let title: String
    let image: URL
    let id: Int
    
    let personaNames: [String]?
}

// A custom error type for internet operation-related failures that don't throw errors by default
enum InternetError: Error {
    case dateFormatFailure(String) // For use with actors' iso 8601 formatters, which don't throw errors when they fail to convert Strings to Dates
    case invalidURL(String)                      // Error when a URL is invalid
    case networkFailure(String)                  // Error for network connection issues
    case serverError(String)                     // Error for receiving an invalid server response
    case dataParsingFailure(String)              // Error for failure in parsing data (e.g., JSON decoding)
    }




class DateFormatter {
    static let isoFormatter = ISO8601DateFormatter()
    
    static func formatFromISO8601(_ string: String) throws -> Date {
        if let formattedDate = isoFormatter.date(from: string) {
            return formattedDate
        } else {
            throw InternetError.dateFormatFailure("Failed to format FM ISO 8601 string \(string) to date")
        }
    }
}
