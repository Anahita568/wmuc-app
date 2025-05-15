//
//  CurrentShowCombine.swift
//  WMUC
//
//  Created by Anahita on 5/8/25.
//

import Combine
import SwiftUI

// Add *once* in the app target
extension CurrentShow where Self: ObservableObject {
    /// Publishes `self` every time any @Published property changes.
    var changePublisher: AnyPublisher<CurrentShow, Never> {
        objectWillChange
            .map { _ in self as CurrentShow }
            .eraseToAnyPublisher()
    }
}
