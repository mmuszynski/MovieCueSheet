//
//  CueSheet.swift
//  Episode V
//
//  Created by Mike Muszynski on 3/15/19.
//  Copyright © 2019 Mike Muszynski. All rights reserved.
//

import Foundation
import AVFoundation

class CueSheet: Codable, ObservableObject {
    
    class var hocus: CueSheet {
        let decoder = PropertyListDecoder()
        let url = Bundle.main.url(forResource: "hocus", withExtension: "cue")!
        return try! decoder.decode(CueSheet.self, from: try! Data(contentsOf: url))
    }
    
    class var empty: CueSheet {
        CueSheet()
    }
    
    class var indy: CueSheet {
        let decoder = PropertyListDecoder()
        let url = URL(fileURLWithPath: "/Users/mike/Desktop/raiders.cue")
        let data = try! Data(contentsOf: url)
        let cue = try! decoder.decode(CueSheet.self, from: data)
        return cue
    }
    
    @Published var cues: Array<Cue> = []
    
    func insertCue(named name: String, startTime: CMTime, endTime: CMTime) {
        self.insertCue(named: name,
                       timeRange: startTime..<endTime)
    }
    
    func insertCue(named name: String, startTime: Double, endTime: Double) {
        self.insertCue(named: name,
                       startTime: CMTimeMakeWithSeconds(startTime, preferredTimescale: defaultTimescale),
                       endTime: CMTimeMakeWithSeconds(endTime, preferredTimescale: defaultTimescale))
    }
    
    func insertCue(named name: String, timeRange: Range<CMTime>) {
        let cue = Cue(name: name,
                      timeRange: timeRange)
        self.insert(cue)
    }
    
    func insert(_ cue: Cue) {
        self.cues.append(cue)
        recomputeCueBoundaries()
    }
    
    func remove(_ cue: Cue) {
        self.cues.removeAll(where: { $0 == cue })
    }
    
    private var defaultTimescale: CMTimeScale = .maxResolution
    
    /// Returns a `Cue` struct for a given CMTime  or `nil` if no cue exists at that time point
    ///
    /// - Parameter time: A time value in `CMTime`
    /// - Returns: A `Cue` struct if there is cue whose range contains the time value, `nil` otherwise
    func cue(atCMTime time: CMTime) -> Cue? {
        return nil
    }
    
    /// Returns a `Cue` sctruct for a given number of seconds or `nil` if no cue exists at that time point
    ///
    /// - Parameter time: A time value in seconds
    /// - Returns: A `Cue` struct if there is cue whose range contains the time value, `nil` otherwise
    func cue(atTimeInSeconds time: Double) -> Cue? {
        return cue(atCMTime: CMTimeMakeWithSeconds(time, preferredTimescale: defaultTimescale))
    }
    
    lazy var cueTimes: [Range<CMTime>] = self.cues.map { $0.timeRange }.sorted(by: { (range1, range2) -> Bool in
        range1.lowerBound < range2.lowerBound
    })
    lazy var cueStarts: [CMTime] = self.cues.map { $0.timeRange.lowerBound }.sorted(by: { (time1, time2) -> Bool in
        time1 < time2
    })
    lazy var cueEnds: [CMTime] = self.cues.map { $0.timeRange.upperBound }.sorted(by: { (time1, time2) -> Bool in
        time1 < time2
    })
    
    func recomputeCueBoundaries() {
        self.cueStarts = self.cues.map { $0.timeRange.lowerBound }.sorted(by: { (time1, time2) -> Bool in
            time1 < time2
        })
        self.cueEnds = self.cues.map { $0.timeRange.upperBound }.sorted(by: { (time1, time2) -> Bool in
            time1 < time2
        })
        self.cueTimes = self.cues.map { $0.timeRange }.sorted(by: { (range1, range2) -> Bool in
            range1.lowerBound < range2.lowerBound
        })
        self.cues.sort { cue1, cue2 in
            cue1.name.localizedStandardCompare(cue2.name) == .orderedAscending
        }
    }
    
    func currentCue(forCMTime time: CMTime) -> Cue? {
        for cue in self.cues {
            if cue.timeRange.contains(time) { return cue }
        }
        
        return nil
    }
    
    var sorted: [Cue] {
        let sorted = self.cues.sorted { (cue1, cue2) -> Bool in
            return cue1.timeRange.lowerBound < cue2.timeRange.lowerBound
        }
        return sorted
    }
    
    func nextCue(forCMTime time: CMTime) -> Cue? {
        //Sort cues by start time
        let sorted = self.cues.sorted { (cue1, cue2) -> Bool in
            return cue1.timeRange.lowerBound < cue2.timeRange.lowerBound
        }
        
        guard !sorted.isEmpty else {
            return nil
        }
        
        for cue in sorted {
            if time < cue.timeRange.lowerBound {
                return cue
            }
        }
        
        return nil
    }
    
    func previousCue(forCMTime time: CMTime) -> Cue? {
        //Sort cues by start time
        let sorted = self.cues.sorted { (cue1, cue2) -> Bool in
            return cue1.timeRange.lowerBound < cue2.timeRange.lowerBound
        }
        
        guard !sorted.isEmpty else {
            return nil
        }
        
        for (index, cue) in sorted.enumerated() {
            if time < cue.timeRange.lowerBound {
                if index > 0 {
                    return sorted[index - 1]
                } else {
                    return nil
                }
            }
        }
        
        return sorted.last!
    }
    
    enum CodingKeys: CodingKey {
        case cues
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cues, forKey: .cues)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.cues = try container.decode(Array<Cue>.self, forKey: .cues)
    }
    
    init() {}
    
    func writeToDisk() throws {
        let path = "/Users/mike/Desktop/raiders.cue"
        let url = URL(fileURLWithPath: path)
        
        let data = try PropertyListEncoder().encode(self)
        try data.write(to: url)
    }
}
