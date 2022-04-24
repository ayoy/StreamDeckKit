//
//  ReceivedEvent.swift
//  
//
//  Created by Dominik Kapusta on 23/04/2022.
//

import Foundation
import SwiftUI

public enum ReceivedEvent: Decodable {
    case keyDown(KeyInfo)
    case keyUp(KeyInfo)
    case willAppear(KeyInfo)
    case willDisappear(KeyInfo)
    case titleParametersDidChange(TitleParametersDidChange)
    case deviceDidConnect(DeviceDidConnect)
    case deviceDidDisconnect(DeviceDidDisconnect)
    case applicationDidLaunch(Application)
    case applicationDidTerminate(Application)
    case systemDidWakeUp
    case propertyInspectorDidAppear(PropertyInspectorInfo)
    case propertyInspectorDidDisappear(PropertyInspectorInfo)
    case sendToPlugin(SendToPlugin)

    enum CodingKeys: String, CodingKey {
        case type = "event"
    }

    // swiftlint:disable:next cyclomatic_complexity
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ReceivedEventType.self, forKey: CodingKeys.type)

        switch type {
        case .keyDown:
            self = .keyDown(try .init(from: decoder))
        case .keyUp:
            self = .keyUp(try .init(from: decoder))
        case .willAppear:
            self = .willAppear(try .init(from: decoder))
        case .willDisappear:
            self = .willDisappear(try .init(from: decoder))
        case .titleParametersDidChange:
            self = .titleParametersDidChange(try .init(from: decoder))
        case .deviceDidConnect:
            self = .deviceDidConnect(try .init(from: decoder))
        case .deviceDidDisconnect:
            self = .deviceDidDisconnect(try .init(from: decoder))
        case .applicationDidLaunch:
            self = .applicationDidLaunch(try .init(from: decoder))
        case .applicationDidTerminate:
            self = .applicationDidTerminate(try .init(from: decoder))
        case .systemDidWakeUp:
            self = .systemDidWakeUp
        case .propertyInspectorDidAppear:
            self = .propertyInspectorDidAppear(try .init(from: decoder))
        case .propertyInspectorDidDisappear:
            self = .propertyInspectorDidDisappear(try .init(from: decoder))
        case .sendToPlugin:
            self = .sendToPlugin(try .init(from: decoder))
        }
    }
}

public enum ReceivedEventType: String, Decodable {
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
    case sendToPlugin
}
