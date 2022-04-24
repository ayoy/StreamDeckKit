//
//  OutgoingEvent.swift
//  StreamDeckKit
//
//  Created by Dominik Kapusta on 19/04/2022.
//

import Foundation
import AppKit

public typealias Context = String
public typealias Settings = [String: String]
public typealias State = UInt

public enum OutgoingEventType: String, Encodable {
    case setSettings
    case getSettings
    case setGlobalSettings
    case getGlobalSettings
    case openURL
    case logMessage
    case setTitle
    case setImage
    case showAlert
    case showOK
    case setState
    case switchToProfile
    case sendToPropertyInspector
}

public protocol OutgoingEvent: Encodable {
    var event: OutgoingEventType { get }
}

protocol ContextEvent: OutgoingEvent {
    var context: Context { get }
}

public struct SetSettings: ContextEvent {

    public init(context: Context, payload: Settings) {
        self.context = context
        self.payload = payload
    }

    public let event: OutgoingEventType = .setSettings
    let context: Context
    let payload: Settings
}

public struct GetSettings: ContextEvent {

    init(context: Context) {
        self.context = context
    }

    public let event: OutgoingEventType = .getSettings
    let context: Context
}

public struct SetGlobalSettings: ContextEvent {

    public init(context: Context, payload: Settings) {
        self.context = context
        self.payload = payload
    }

    public let event: OutgoingEventType = .setGlobalSettings
    let context: Context
    let payload: Settings
}

public struct GetGlobalSettings: ContextEvent {

    init(context: Context) {
        self.context = context
    }

    public let event: OutgoingEventType = .getGlobalSettings
    let context: Context
}

struct OpenURL: OutgoingEvent {

    init(url: URL) {
        payload = .init(url: url.absoluteString)
    }

    public let event: OutgoingEventType = .openURL
    let payload: Payload

    struct Payload: Encodable {
        let url: String
    }
}

struct LogMessage: OutgoingEvent {

    init(message: String) {
        payload = .init(message: message)
    }

    public let event: OutgoingEventType = .logMessage
    let payload: Payload

    struct Payload: Encodable {
        let message: String
    }
}

public struct SetTitle: ContextEvent {

    public init(context: Context, title: String, target: Target = .hardwareAndSoftware, state: State? = nil) {
        self.context = context
        payload = .init(title: title, target: target, state: state)
    }

    public let event: OutgoingEventType = .setTitle
    let context: Context
    let payload: Payload

    struct Payload: Encodable {
        let title: String
        let target: Target
        let state: State?
    }
}

public struct SetImage: ContextEvent {

    public init(context: Context, image: Image, target: Target = .hardwareAndSoftware, state: State? = nil) {
        self.context = context
        payload = .init(image: image, target: target, state: state)
    }

    public let event: OutgoingEventType = .setImage
    let context: Context
    let payload: Payload

    struct Payload: Encodable {
        let image: Image
        let target: Target
        let state: State?
    }
}

public struct SetState: ContextEvent {

    public init(state: State, context: Context) {
        self.context = context
        self.payload = .init(state: state)
    }

    public let event: OutgoingEventType = .setState
    let context: Context
    let payload: Payload

    struct Payload: Encodable {
        let state: State
    }
}

public struct SwitchToProfile: ContextEvent {

    public init(context: Context, device: String, profileName: String) {
        self.context = context
        self.device = device
        payload = .init(profile: profileName)
    }

    public let event: OutgoingEventType = .switchToProfile
    let context: Context
    let device: String
    let payload: Payload

    struct Payload: Encodable {
        let profile: String
    }
}

public struct SendToPropertyInspector: ContextEvent {

    public init(action: String, context: Context, payload: [String: String]) {
        self.action = action
        self.context = context
        self.payload = payload
    }

    public let event: OutgoingEventType = .sendToPropertyInspector
    let action: String
    let context: Context
    let payload: [String: String]
}

// MARK: - Internal

struct RegisterPluginMessage: Encodable {
    let event: String
    let uuid: String
}
