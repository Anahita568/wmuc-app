//
//  MediaBarManager.swift
//  Radio practice
//
//  Created by Akash Balenalli on 10/8/23.
//

import Foundation

protocol MediaBarManager {
    var name: String { get set }
    var djs: [String] { get set }
    
    func updateMedia(name: String, djs: [String])
}
