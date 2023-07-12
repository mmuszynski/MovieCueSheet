//
//  Cue.swift
//  MovieNudger
//
//  Created by Mike Muszynski on 7/6/23.
//

import SwiftUI
import AVFoundation

class Cue: Codable, Identifiable, ObservableObject {
    var id: UUID = UUID()
    var name: String
    var timeRange: Range<CMTime>
    
    /*
     - MARK: Codable Conformance
     ==========================================================================================
     Because Range<CMTime> isn't codable. But CMTime is. Should this be rewritten before it gets
     used for too many movies?
     ==========================================================================================
     */
    
    enum CodingKeys: String, CodingKey {
        case name
        case startTime
        case startTimescale
        case endTime
        case endTimescale
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        
        let start = try values.decode(CMTimeValue.self, forKey: .startTime)
        let startTimescale = try values.decode(Int32.self, forKey: .startTimescale)
        let startCMTime = CMTime(value: start, timescale: startTimescale)
        
        let end = try values.decode(CMTimeValue.self, forKey: .endTime)
        let endTimescale = try values.decode(Int32.self, forKey: .endTimescale)
        let endCMTime = CMTime(value: end, timescale: endTimescale)
        
        timeRange = startCMTime..<endCMTime
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(timeRange.lowerBound.value, forKey: .startTime)
        try container.encode(timeRange.lowerBound.timescale, forKey: .startTimescale)
        try container.encode(timeRange.upperBound.value, forKey: .endTime)
        try container.encode(timeRange.upperBound.timescale, forKey: .endTimescale)
    }
    
    init(name: String, timeRange: Range<CMTime>) {
        self.name = name
        self.timeRange = timeRange
    }
    
    var startTime: CMTime {
        get {
            timeRange.lowerBound
        }
        set {
            guard newValue < timeRange.upperBound else {
                return
            }
            self.timeRange = newValue..<timeRange.upperBound
        }
    }
    
    var endTime: CMTime {
        get {
            timeRange.upperBound
        }
        set {
            guard timeRange.lowerBound < newValue else {
                return
            }
            self.timeRange = timeRange.lowerBound..<newValue
        }
    }
}

extension Cue: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Cue, rhs: Cue) -> Bool {
        lhs.id == rhs.id
    }
}

extension Cue {
    static var example: Cue {
        Cue(name: "1E1", timeRange: .indefinite)
    }
}
