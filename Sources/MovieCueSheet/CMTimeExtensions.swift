//
//  File.swift
//  
//
//  Created by Mike Muszynski on 7/12/23.
//

import AVFoundation

extension CMTimeScale {
    static let nsec_per_sec = CMTimeScale(NSEC_PER_SEC)
    static let maxResolution = CMTimeScale.nsec_per_sec
}

extension Range<CMTime> {
    static let indefinite: Self = CMTime.zero..<CMTime.indefinite
}
