//
//  IncomingMessage.swift
//  
//
//  Created by Dominik Kapusta on 23/04/2022.
//

import Foundation

// swiftlint:disable nesting

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
