//
//  String+PluginPath.swift
//  StreamDeckKit
//
//  Created by Dominik Kapusta on 19/04/2022.
//

import Foundation

public extension String {

    static var pluginPath: String? {
        let bundle = Bundle.init(for: PluginInterface.self)

        return bundle.executableURL?.pluginPath
    }
}

extension URL {
    var pluginPath: String? {
        var pluginURL = self

        while true {
            if ["/", ".."].contains(pluginURL.lastPathComponent) {
                return nil
            }

            if pluginURL.pathExtension == "sdPlugin" {
                return pluginURL.path
            }

            pluginURL = pluginURL.deletingLastPathComponent()
        }

    }
}
