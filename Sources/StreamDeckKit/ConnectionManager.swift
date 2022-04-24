//
//  ConnectionManager.swift
//  StreamDeckKit
//
//  Created by Dominik Kapusta on 19/04/2022.
//

import Foundation
import Combine
import os

public final class ConnectionManager {

    public enum InitError: Error {
        case invalidInfo
    }

    public weak var delegate: Pluggable?

    // MARK: - APIs

    public func send<Event: OutgoingEvent>(_ event: Event) async throws {
        try await sendMessage(event)
    }

    public init(port: Int, pluginUUID: String, registerEvent: String, info: String, delegate: Pluggable) throws {
        guard let infoData = info.data(using: .utf8),
              let infoJSON = try? JSONSerialization.jsonObject(with: infoData, options: .mutableContainers) as? [String: Any]
        else {
            throw InitError.invalidInfo
        }

        urlSession = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: operationQueue)

        self.port = port
        self.pluginUUID = pluginUUID
        self.registerEvent = registerEvent
        self.delegate = delegate

        let applicationInfo = infoJSON[.ESD.applicationInfo] as? [String: String]

        applicationVersion = applicationInfo?[.ESD.applicationInfoVersion]
        applicationPlatform = applicationInfo?[.ESD.applicationInfoPlatform]
        applicationLanguage = applicationInfo?[.ESD.applicationInfoLanguage]
        devicesInfo = infoJSON[.ESD.devicesInfo] as? String

        let request = URLRequest(url: .init(string: "ws://127.0.0.1:\(port)")!)
        socket = urlSession.webSocketTask(with: request)

        sessionDelegate.connectionManager = self

        socket.resume()
        readFromSocket()
    }

    // MARK: - Private

    private let port: Int
    private let pluginUUID: String
    private let registerEvent: String
    private let applicationVersion: String?
    private let applicationPlatform: String?
    private let applicationLanguage: String?
    private let devicesInfo: String?

    private let operationQueue = OperationQueue()
    private let urlSession: URLSession
    private let sessionDelegate: SessionDelegate = .init()
    private let socket: URLSessionWebSocketTask
    private var jsonDecoder = JSONDecoder()
    private var jsonEncoder = JSONEncoder()

    private func sendMessage<Message: Encodable>(_ message: Message) async throws {
        let jsonData = try jsonEncoder.encode(message)
        do {
            try await socket.send(.data(jsonData))
        } catch {
            os_log("Failed to send message: ${public}s", log: .streamDeckKit, type: .error, error.localizedDescription)
            throw error
        }
    }

    fileprivate func registerPlugin() async throws {
        let message = RegisterPluginMessage(event: registerEvent, uuid: pluginUUID)
        os_log("Registering plugin %{public}s", log: .streamDeckKit, type: .debug, pluginUUID)
        try await sendMessage(message)
    }

    private func readFromSocket() {
        Task {
            do {
                let receivedData = try await socket.receive().data()
                let event = try jsonDecoder.decode(ReceivedEvent.self, from: receivedData)
                delegate?.didReceive(event: event)

                readFromSocket()

            } catch {
                switch error {
                case let decodingError as DecodingError:
                    os_log("Error while decoding event: %{public}s", log: .streamDeckKit, type: .error, decodingError.localizedDescription)
                default:
                    os_log("Error reading from socket: %{public}s ", log: .streamDeckKit, type: .error, error.localizedDescription)
                }
            }
        }
    }
}

class SessionDelegate: NSObject, URLSessionDelegate, URLSessionWebSocketDelegate {

    weak var connectionManager: ConnectionManager?

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        Task {
            do {
                try await connectionManager?.registerPlugin()
            } catch {
                os_log("Failed to register plugin: ${public}s", log: .streamDeckKit, type: .error, error.localizedDescription)
            }
        }
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        switch closeCode {
        case .normalClosure:
            exit(0)
        default:
            let reasonString: String = reason.flatMap({ String.init(data: $0, encoding: .utf8) }) ?? ""
            os_log(
                "Websocket closed unexpectedly (code %{public}s, reason: %{public}s",
                log: .app,
                type: .error,
                closeCode.rawValue,
                reasonString
            )
        }
    }
}

private extension ConnectionManager {
    struct IncomingMessageDecodingError: Error {}
}

extension URLSessionWebSocketTask.Message {
    func data() throws -> Data {
        switch self {
        case let .data(data):
            os_log("Received data message: %{public}s", log: .streamDeckKit, type: .error, String(reflecting: String(bytes: data, encoding: .utf8)))
            return data

        case let .string(stringData):
            os_log("Received string message: %{public}s ", log: .streamDeckKit, type: .error, String(reflecting: stringData))

            guard let data = stringData.data(using: .utf8) else {
                os_log("Failed to encode string data", log: .streamDeckKit, type: .error)
                throw ConnectionManager.IncomingMessageDecodingError()
            }

            return data

        @unknown default:
            throw ConnectionManager.IncomingMessageDecodingError()
        }
    }
}
