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

    func keyDown(
        forAction action: String,
        withContext context: Context,
        withPayload payload: [AnyHashable: Any],
        forDevice deviceID: String
    )

    func keyUp(
        forAction action: String,
        withContext context: Context,
        withPayload payload: [AnyHashable: Any],
        forDevice deviceID: String
    )

    func willAppear(
        forAction action: String,
        withContext context: Context,
        withPayload payload: [AnyHashable: Any],
        forDevice deviceID: String
    )

    func willDisappear(
        forAction action: String,
        withContext context: Context,
        withPayload payload: [AnyHashable: Any],
        forDevice deviceID: String
    )

    func propertyInspectorDidAppear(
        forAction action: String,
        withContext context: Context,
        withPayload payload: [AnyHashable: Any],
        forDevice deviceID: String
    )

    func propertyInspectorDidDisappear(
        forAction action: String,
        withContext context: Context,
        withPayload payload: [AnyHashable: Any],
        forDevice deviceID: String
    )

    func sendToPlugin(
        forAction action: String,
        withContext context: Context,
        withPayload payload: [AnyHashable: Any],
        forDevice deviceID: String
    )

    func deviceDidConnect(_ deviceID: String, withDeviceInfo deviceInfo: [AnyHashable: Any])
    func deviceDidDisconnect(_ deviceID: String)

    func applicationDidLaunch(_ applicationInfo: [AnyHashable: Any])
    func applicationDidTerminate(_ applicationInfo: [AnyHashable: Any])
}
