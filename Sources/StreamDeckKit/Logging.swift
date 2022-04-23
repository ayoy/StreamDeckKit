//
//  Logging.swift
//  
//
//  Created by Dominik Kapusta on 22/04/2022.
//

import Foundation
import os

public enum Logging {
    public static var log: OSLog = .app
}

extension OSLog {

    static var streamDeckKit: OSLog {
        Logging.log
    }

    static var app: OSLog = OSLog(subsystem: "StreamDeckKit", category: "StreamDeckKit")
}
