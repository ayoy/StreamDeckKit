//
//  File.swift
//  
//
//  Created by Dominik Kapusta on 23/04/2022.
//

import Foundation

public enum ReceivedEvent: String {
    case keyDown
    case keyUp
    case willAppear
    case willDisappear
    case titleParametersDidChange
    case deviceDidConnect
    case deviceDidDisconnect
    case applicationDidLaunch
    case applicationDidTerminate
    case systemDidWakeUp
    case propertyInspectorDidAppear
    case propertyInspectorDidDisappear
}
