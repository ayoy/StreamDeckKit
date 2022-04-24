//
//  EventsProtocol.swift
//  StreamDeckKit
//
//  Created by Dominik Kapusta on 19/04/2022.
//

import Foundation

public typealias Context = String

public protocol Pluggable: AnyObject {

    var connectionManager: ConnectionManager? { get set }

    func didReceive(event: ReceivedEvent)
}
