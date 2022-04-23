//
//  ConnectionManager.swift
//  StreamDeckKit
//
//  Created by Dominik Kapusta on 19/04/2022.
//

import Foundation
import os

public final class ConnectionManager {

    public enum InitError: Error {
        case invalidInfo
    }

    public weak var delegate: EventsProtocol?

    public init(port: Int, pluginUUID: String, registerEvent: String, info: String, delegate: EventsProtocol) throws {
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

    // MARK: - APIs

    public func setTitle(_ title: String?, withContext context: Context, target: Target) async {
        let message = SetTitleMessage(title: title, context: context, target: target)
        await sendMessage(message)
    }

    public func setImage(_ base64Image: String?, withContext context: Context, target: Target) async {
        let message = SetImageMessage(base64Image: base64Image, context: context, target: target)
        await sendMessage(message)
    }

    public func showAlert(forContext context: Context) async {
        let message = ShowAlertMessage(context: context)
        await sendMessage(message)
    }

    public func showOK(forContext context: Context) async {
        let message = ShowOKMessage(context: context)
        await sendMessage(message)
    }

    public func setSettings(_ settings: [String: String], forContext context: Context) async {
        let message = SetSettingsMessage(settings: settings, context: context)
        await sendMessage(message)
    }

    public func setState(_ state: Int, forContext context: Context) async {
        let message = SetStateMessage(state: state, context: context)
        await sendMessage(message)
    }

    public func logMessage(_ message: String) async {
        let message = LogMessage(message: message)
        await sendMessage(message)
    }

    public func sendToPropertyInspector(_ action: String, context: Context, payload: [String: String]) async {
        let message = SendToPropertyInspectorMessage(action: action, context: context, payload: payload)
        await sendMessage(message)
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

    private func sendMessage<M: Message & Encodable>(_ message: M) async {
        guard let jsonData = try? JSONEncoder().encode(message) else {
            os_log("Failed to serialize message %{public}s ", log: .streamDeckKit, type: .error, message.event)
            return
        }

        do {
            try await socket.send(.data(jsonData))
        } catch let error {
            os_log("Failed to send message %{public}s: ${public}s", log: .streamDeckKit, type: .error, message.event, error.localizedDescription)
        }
    }

    fileprivate func registerPlugin() async {
        let message = RegisterPluginMessage(event: registerEvent, uuid: pluginUUID)
        os_log("Registering plugin %{public}s", log: .streamDeckKit, type: .debug, pluginUUID)
        await sendMessage(message)
    }

    private func handleEvent(_ event: ReceivedEvent, data: Data, json: [String: Any]) {

        do {
            switch event {
            case .keyDown:
                let message = try jsonDecoder.decode(IncomingMessage.KeyInfo.self, from: data)
                delegate?.keyDown(message)

            case .keyUp:
                let message = try jsonDecoder.decode(IncomingMessage.KeyInfo.self, from: data)
                delegate?.keyUp(message)

            case .willAppear:
                let message = try jsonDecoder.decode(IncomingMessage.KeyInfo.self, from: data)
                delegate?.willAppear(message)

            case .willDisappear:
                let message = try jsonDecoder.decode(IncomingMessage.KeyInfo.self, from: data)
                delegate?.willDisappear(message)

            case .titleParametersDidChange:
                let message = try jsonDecoder.decode(IncomingMessage.TitleParametersDidChange.self, from: data)
                delegate?.titleParametersDidChange(message)

            case .deviceDidConnect:
                let message = try jsonDecoder.decode(IncomingMessage.DeviceDidConnect.self, from: data)
                delegate?.deviceDidConnect(message)

            case .deviceDidDisconnect:
                let message = try jsonDecoder.decode(IncomingMessage.DeviceDidDisconnect.self, from: data)
                delegate?.deviceDidDisconnect(message)

            case .applicationDidLaunch:
                let message = try jsonDecoder.decode(IncomingMessage.Application.self, from: data)
                delegate?.applicationDidLaunch(message)

            case .applicationDidTerminate:
                let message = try jsonDecoder.decode(IncomingMessage.Application.self, from: data)
                delegate?.applicationDidTerminate(message)

            case .systemDidWakeUp:
                delegate?.systemDidWakeUp()

            case .propertyInspectorDidAppear:
                let message = try jsonDecoder.decode(IncomingMessage.PropertyInspectorInfo.self, from: data)
                delegate?.propertyInspectorDidAppear(message)

            case .propertyInspectorDidDisappear:
                let message = try jsonDecoder.decode(IncomingMessage.PropertyInspectorInfo.self, from: data)
                delegate?.propertyInspectorDidDisappear(message)
            }

        } catch {
            if let decodingError = error as? DecodingError {
                os_log(
                    "Error while decoding message for %{public}s event: %{public}s",
                    log: .streamDeckKit,
                    type: .error,
                    event.rawValue, decodingError.localizedDescription
                )
            }
        }
    }

    private func readFromSocket() {
        Task {
            do {
                let message = try await socket.receive()

                switch message {
                case let .data(data):
                    os_log("Received data message: %{public}s", log: .streamDeckKit, type: .error, String(reflecting: String(bytes: data, encoding: .utf8)))

                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let eventRawValue = json[.ESD.commonEvent] as? String,
                          let event = ReceivedEvent(rawValue: eventRawValue)
                    else {
                        os_log("Incoming message missing 'event' field", log: .streamDeckKit, type: .error)
                        break
                    }

                    handleEvent(event, data: data, json: json)

                case let .string(stringData):
                    os_log("Received string message: %{public}s ", log: .streamDeckKit, type: .error, String(reflecting: stringData))

                    guard let data = stringData.data(using: .utf8),
                          let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let eventRawValue = json[.ESD.commonEvent] as? String,
                          let event = ReceivedEvent(rawValue: eventRawValue)
                    else {
                        os_log("Incoming message missing 'event' field", log: .streamDeckKit, type: .error)
                        break
                    }

                    handleEvent(event, data: data, json: json)

                @unknown default:
                    break
                }
                readFromSocket()

            } catch {
                os_log("Error reading from socket: %{public}s ", log: .streamDeckKit, type: .error, error.localizedDescription)
            }
        }
    }
}

class SessionDelegate: NSObject, URLSessionDelegate, URLSessionWebSocketDelegate {

    weak var connectionManager: ConnectionManager?

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        Task {
            await connectionManager?.registerPlugin()
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
