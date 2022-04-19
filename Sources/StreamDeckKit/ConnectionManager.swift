//
//  ConnectionManager.swift
//  StreamDeckKit
//
//  Created by Dominik Kapusta on 19/04/2022.
//

import Foundation

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

        self.urlSession = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: operationQueue)

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
        socket = URLSession.shared.webSocketTask(with: request)

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

    private func sendMessage<M: Message & Encodable>(_ message: M) async {
        guard let jsonData = try? JSONEncoder().encode(message) else {
            print("Failed to serialize message \(message.event): serialization error", to: &Current.standardError)
            return
        }

        do {
            try await socket.send(.data(jsonData))
        } catch let error {
            print("Failed to send message \(message.event): \(error.localizedDescription)", to: &Current.standardError)
        }
    }

    fileprivate func registerPlugin() async {
        let message = RegisterPluginMessage(event: registerEvent, uuid: pluginUUID)
        await sendMessage(message)
    }

    private func handleIncomingMessage(_ message: [String: Any]) {
        guard let event = message[.ESD.commonEvent] as? String,
                let context = message[.ESD.commonContext] as? String,
                let action = message[.ESD.commonAction] as? String,
                let payload = message[.ESD.commonPayload] as? [AnyHashable: Any],
                let deviceID = message[.ESD.commonDevice] as? String
        else {
            print("Message incomplete", to: &Current.standardError)
            return
        }

        switch event {
        case .ESD.eventKeyDown:
            delegate?.keyDown(forAction: action, withContext: context, withPayload: payload, forDevice: deviceID)
        case .ESD.eventKeyUp:
            delegate?.keyUp(forAction: action, withContext: context, withPayload: payload, forDevice: deviceID)
        case .ESD.eventWillAppear:
            delegate?.willAppear(forAction: action, withContext: context, withPayload: payload, forDevice: deviceID)
        case .ESD.eventWillDisappear:
            delegate?.willDisappear(forAction: action, withContext: context, withPayload: payload, forDevice: deviceID)
        case .ESD.eventDeviceDidConnect:
            let deviceInfo: [AnyHashable: Any] = message[.ESD.commonDeviceInfo] as? [AnyHashable: Any] ?? [:]
            delegate?.deviceDidConnect(deviceID, withDeviceInfo: deviceInfo)
        case .ESD.eventDeviceDidDisconnect:
            delegate?.deviceDidDisconnect(deviceID)
        case .ESD.eventApplicationDidLaunch:
            delegate?.applicationDidLaunch(payload)
        case .ESD.eventApplicationDidTerminate:
            delegate?.applicationDidTerminate(payload)
        default:
            break
        }
    }

    private func readFromSocket() {
        Task {
            do {
                let message = try await socket.receive()

                switch message {
                case let .data(data):
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        handleIncomingMessage(json)
                    }
                case let .string(stringData):
                    if let data = stringData.data(using: .utf8), let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        handleIncomingMessage(json)
                    }
                @unknown default:
                    break
                }

            } catch {
                print("Error reading from socket: \(error.localizedDescription)", to: &Current.standardError)
            }
            readFromSocket()
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
            print("Websocket closed unexpectedly (code \(closeCode), reason: \(reasonString)", to: &Current.standardError)
        }
    }
}
