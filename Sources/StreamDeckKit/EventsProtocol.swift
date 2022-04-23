//
//  EventsProtocol.swift
//  StreamDeckKit
//
//  Created by Dominik Kapusta on 19/04/2022.
//

import Foundation

public typealias Context = String

public protocol EventsProtocol: AnyObject {

    var connectionManager: ConnectionManager? { get set }

    func keyDown(_ message: IncomingMessage.KeyInfo)
    func keyUp(_ message: IncomingMessage.KeyInfo)

    func willAppear(_ message: IncomingMessage.KeyInfo)
    func willDisappear(_ message: IncomingMessage.KeyInfo)

    func titleParametersDidChange(_ message: IncomingMessage.TitleParametersDidChange)

    func deviceDidConnect(_ message: IncomingMessage.DeviceDidConnect)
    func deviceDidDisconnect(_ message: IncomingMessage.DeviceDidDisconnect)

    func applicationDidLaunch(_ message: IncomingMessage.Application)
    func applicationDidTerminate(_ message: IncomingMessage.Application)

    func systemDidWakeUp()

    func propertyInspectorDidAppear(_ message: IncomingMessage.PropertyInspectorInfo)
    func propertyInspectorDidDisappear(_ message: IncomingMessage.PropertyInspectorInfo)

    func sendToPlugin(_ message: IncomingMessage.SendToPlugin)
}
