//
//  ConnectionManager.swift
//  
//
//  Created by Dominik Kapusta on 24/04/2022.
//

import Foundation
import Combine
import os

final class ConnectionManager: NSObject {

    let receivedEventSubject = PassthroughSubject<IncomingEvent, Never>()

    func sendMessage<Message: Encodable>(_ message: Message) async throws {
        let jsonData = try jsonEncoder.encode(message)
        do {
            try await socket.send(.data(jsonData))
        } catch {
            os_log("Failed to send message: ${public}s", log: .streamDeckKit, type: .error, error.localizedDescription)
            throw error
        }
    }

    init(parameters: CommandLineParameters) {
        port = parameters.port
        pluginUUID = parameters.pluginUUID
        registerEvent = parameters.registerEvent
    }

    func connect() {
        let request = URLRequest(url: .init(string: "ws://127.0.0.1:\(port)")!)
        socket = urlSession.webSocketTask(with: request)

        socket.resume()
        readFromSocket()
    }

    // MARK: - Private

    private lazy var urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: operationQueue)
    private let operationQueue = OperationQueue()
    private let port: Int
    private let pluginUUID: String
    private let registerEvent: String
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var socket: URLSessionWebSocketTask!

    private var jsonDecoder = JSONDecoder()
    private var jsonEncoder = JSONEncoder()

    private func registerPlugin() async throws {
        let message = RegisterPluginMessage(event: registerEvent, uuid: pluginUUID)
        os_log("Registering plugin %{public}s", log: .streamDeckKit, type: .debug, pluginUUID)
        try await sendMessage(message)
    }

    private func readFromSocket() {
        Task {
            do {
                let receivedData = try await socket.receive().data()
                do {
                    let event = try jsonDecoder.decode(IncomingEvent.self, from: receivedData)
                    receivedEventSubject.send(event)

                    readFromSocket()
                } catch {
                    if let decodingError = error as? DecodingError {
                        os_log(
                            "Error while decoding event '%{public}s': %{public}s",
                            log: .streamDeckKit,
                            type: .error,
                            String(reflecting: String(bytes: receivedData, encoding: .utf8)),
                            decodingError.localizedDescription
                        )
                    }
                }
            } catch {
                os_log("Error reading from socket: %{public}s ", log: .streamDeckKit, type: .error, error.localizedDescription)
            }
        }
    }
}

extension ConnectionManager: URLSessionDelegate, URLSessionWebSocketDelegate {

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        Task {
            do {
                try await registerPlugin()
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
