//
//  PluginInterface.swift
//  StreamDeckKit
//
//  Created by Dominik Kapusta on 19/04/2022.
//

import Foundation
import Combine
import os

public final class PluginInterface {

    public enum InitError: Error {
        case invalidInfo
    }

    // MARK: - APIs

    public func send<Event: OutgoingEvent>(_ event: Event) async throws {
        try await connectionManager.sendMessage(event)
    }

    public private(set) lazy var receivedEventPublisher: AnyPublisher<IncomingEvent, Never> = {
        receivedEventSubject.eraseToAnyPublisher()
    }()

    public init(parameters: CommandLineParameters) throws {
        guard let infoData = parameters.info.data(using: .utf8),
              let infoJSON = try? JSONSerialization.jsonObject(with: infoData, options: .mutableContainers) as? [String: Any]
        else {
            throw InitError.invalidInfo
        }

        let applicationInfo = infoJSON[.ESD.applicationInfo] as? [String: String]

        applicationVersion = applicationInfo?[.ESD.applicationInfoVersion]
        applicationPlatform = applicationInfo?[.ESD.applicationInfoPlatform]
        applicationLanguage = applicationInfo?[.ESD.applicationInfoLanguage]
        devicesInfo = infoJSON[.ESD.devicesInfo] as? String

        connectionManager = ConnectionManager(parameters: parameters)
        connectionManager.pluginInterface = self
    }

    // MARK: - Internal

    let receivedEventSubject = PassthroughSubject<IncomingEvent, Never>()

    // MARK: - Private

    private let applicationVersion: String?
    private let applicationPlatform: String?
    private let applicationLanguage: String?
    private let devicesInfo: String?

    private let connectionManager: ConnectionManager
}
