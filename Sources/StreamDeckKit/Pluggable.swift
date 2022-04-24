//
//  EventsProtocol.swift
//  StreamDeckKit
//
//  Created by Dominik Kapusta on 19/04/2022.
//

import Foundation

public protocol Pluggable: AnyObject {

    var connectionManager: ConnectionManager? { get set }

    func didReceive(event: IncomingEvent)
}
