//
//  CommandLineParameters.swift
//  StreamDeckKit
//
//  Created by Dominik Kapusta on 19/04/2022.
//

import Foundation

public struct CommandLineParameters {

    public enum ParameterError: Error {
        case wrongNumberOfParameters(Int, expected: Int)
        case wrongArguments([String])
        case unexpectedParameter(String)
        case invalidParameter(String, value: String)
    }

    public private(set) var port: Int = 0
    public private(set) var pluginUUID: String = ""
    public private(set) var registerEvent: String = ""
    public private(set) var info: String = ""

    public init(_ processInfo: ProcessInfo) throws {
        try ProcessInfo.processInfo.arguments
            .dropFirst()
            .commandLineParametersDictionary()
            .forEach { (parameter, value) in

                switch parameter {
                case .ESD.portParameter:
                    guard let portValue = Int(value) else {
                        throw ParameterError.invalidParameter(parameter, value: value)
                    }
                    port = portValue
                case .ESD.pluginUUIDParameter:
                    guard !value.isEmpty else {
                        throw ParameterError.invalidParameter(parameter, value: value)
                    }
                    pluginUUID = value
                case .ESD.registerEventParameter:
                    guard !value.isEmpty else {
                        throw ParameterError.invalidParameter(parameter, value: value)
                    }
                    registerEvent = value
                case .ESD.infoParameter:
                    guard !value.isEmpty else {
                        throw ParameterError.invalidParameter(parameter, value: value)
                    }
                    info = value
                default:
                    throw ParameterError.unexpectedParameter(parameter)
                }

            }
    }
}

extension RandomAccessCollection where Element == String {

    func commandLineParametersDictionary() throws -> [String: String] {
        guard count == 8 else {
            throw CommandLineParameters.ParameterError.wrongNumberOfParameters(count, expected: 8)
        }

        let parametersDict: [String: String] = {
            var dict: [String: String] = [:]

            var i = 0

            while i < count {
                dict[self[index(startIndex, offsetBy: i)]] = self[index(startIndex, offsetBy: i+1)]
                i += 2
            }

            return dict
        }()

        guard Set(parametersDict.keys) == Self.requiredParameters else {
            throw CommandLineParameters.ParameterError.wrongArguments(Array(self))
        }

        return parametersDict
    }

    private static var requiredParameters: Set<String> {
        [
            .ESD.portParameter,
            .ESD.pluginUUIDParameter,
            .ESD.registerEventParameter,
            .ESD.infoParameter
        ]
    }
}
