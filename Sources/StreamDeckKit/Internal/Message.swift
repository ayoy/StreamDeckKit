//
//  Message.swift
//  StreamDeckKit
//
//  Created by Dominik Kapusta on 19/04/2022.
//

import Foundation

protocol Message {
    var event: String { get }
}

struct RegisterPluginMessage: Message, Encodable {
    let event: String
    let uuid: String
}

struct SetTitleMessage: Message, Encodable {
    let event: String = .ESD.eventSetTitle
    let context: Context
    let payload: Payload

    init(title: String?, context: String, target: Target) {
        self.context = context
        self.payload = .init(title: title, target: target)
    }

    struct Payload: Encodable {
        let title: String?
        let target: Target
    }
}

struct SetImageMessage: Message, Encodable {
    let event: String = .ESD.eventSetImage
    let context: Context
    let payload: Payload

    init(base64Image: String?, context: String, target: Target) {
        self.context = context
        self.payload = .init(image: base64Image, target: target)
    }

    struct Payload: Encodable {
        let image: String?
        let target: Target
    }
}

struct ShowAlertMessage: Message, Encodable {
    let event: String = .ESD.eventShowAlert
    let context: Context
}

struct ShowOKMessage: Message, Encodable {
    let event: String = .ESD.eventShowOK
    let context: Context
}

struct SetSettingsMessage: Message, Encodable {
    let event: String = .ESD.eventSetSettings
    let settings: [String: String]
    let context: Context

    enum CodingKeys: String, CodingKey {
        case event, context, settings = "payload"
    }
}

struct SetStateMessage: Message, Encodable {
    let event: String = .ESD.eventSetState
    let context: Context
    let payload: Payload

    init(state: Int, context: String) {
        self.context = context
        self.payload = .init(state: state)
    }

    struct Payload: Encodable {
        let state: Int
    }
}

struct LogMessage: Message, Encodable {
    let event: String = .ESD.eventLogMessage
    let payload: Payload

    init(message: String) {
        self.payload = .init(message: message)
    }

    struct Payload: Encodable {
        let message: String
    }
}

struct SendToPropertyInspectorMessage: Message, Encodable {
    let event: String = .ESD.eventSendToPropertyInspector
    let action: String
    let context: Context
    let payload: [String: String]
}
