//
//  IncomingEvent.swift
//  
//
//  Created by Dominik Kapusta on 23/04/2022.
//

import Foundation
import SwiftUI

public enum IncomingEvent: Decodable {
    case didReceiveSettings(DidReceiveSettings)
    case didReceiveGlobalSettings(DidReceiveSettings)
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
        let type = try container.decode(IncomingEventType.self, forKey: CodingKeys.type)

        switch type {
        case .didReceiveSettings:
            self = .didReceiveSettings(try .init(from: decoder))
        case .didReceiveGlobalSettings:
            self = .didReceiveGlobalSettings(try .init(from: decoder))
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

public enum IncomingEventType: String, Decodable {
    case didReceiveSettings
    case didReceiveGlobalSettings
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

// MARK: - Convenience Data models

public struct DeviceInfo: Decodable {
    public let name: String
    public let size: Size
    public let type: DeviceType
}

public struct Size: Decodable {
    public let columns: Int
    public let rows: Int
}

public struct Coordinates: Decodable {
    public let column: Int
    public let row: Int
}

public enum TitleAlignment: String, Decodable {
    case top, middle, bottom
}

// MARK: - IncomingMessage

public protocol IncomingMessage: Decodable {}

public struct EmptyMessage: IncomingMessage {}

public struct DeviceDidConnect: IncomingMessage {
    public let device: String
    public let deviceInfo: DeviceInfo
}

public struct DeviceDidDisconnect: IncomingMessage {
    public let device: String

}

public struct DidReceiveSettings: IncomingMessage {
    public let device: String
    public let action: String
    public let context: String
    public let payload: Payload

    public struct Payload: Decodable {
        public let coordinates: Coordinates
        public let isInMultiAction: Bool
        public let settings: [String: String]
    }
}

public struct DidReceiveGlobalSettings: IncomingMessage {
    public let payload: Payload

    public struct Payload: Decodable {
        public let coordinates: Coordinates
        public let isInMultiAction: Bool
        public let settings: [String: String]
    }
}

public struct KeyInfo: IncomingMessage {
    public let device: String
    public let action: String
    public let context: String
    public let payload: Payload

    public struct Payload: Decodable {
        public let coordinates: Coordinates
        public let isInMultiAction: Bool
        public let settings: [String: String]
    }
}

public struct PropertyInspectorInfo: IncomingMessage {
    public let device: String
    public let action: String
    public let context: String
}

public struct TitleParametersDidChange: IncomingMessage {
    public let device: String
    public let action: String
    public let context: String
    public let payload: Payload

    public struct Payload: Decodable {
        public let coordinates: Coordinates
        public let settings: [String: String]
        public let state: Int
        public let title: String
        public let titleParameters: TitleParameters

        // swiftlint:disable:next nesting
        public struct TitleParameters: Decodable {
            public let fontFamily: String
            public let fontSize: Int
            public let fontStyle: String
            public let fontUnderline: Bool
            public let showTitle: Bool
            public let titleAlignment: TitleAlignment
            public let titleColor: String
        }
    }
}

public struct Application: IncomingMessage {
    public struct Payload: Decodable {
        public let application: String
    }
}

public struct SendToPlugin: IncomingMessage {
    public let action: String
    public let context: String
    public let payload: Payload

    public struct Payload: Decodable {
        public let command: String
    }
}
