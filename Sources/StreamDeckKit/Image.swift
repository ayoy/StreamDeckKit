//
//  Image.swift
//  
//
//  Created by Dominik Kapusta on 24/04/2022.
//

import Foundation

public enum Image: Encodable {
    case png(atURL: URL)
    case jpg(atURL: URL)
    case bmp(atURL: URL)
    case svg(atURL: URL)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        let imageData: String = try Data(contentsOf: url).base64EncodedString()
        try container.encode(base64Prefix + imageData)
    }

    var url: URL {
        switch self {
        case let .png(atURL: url), let .bmp(atURL: url), let .jpg(atURL: url), let .svg(atURL: url):
            return url
        }
    }

    var base64Prefix: String {
        switch self {
        case .png:
            return "data:image/png;base64,"
        case .jpg:
            return "data:image/jpg;base64,"
        case .bmp:
            return "data:image/bmp;base64,"
        case .svg:
            return "data:image/svg+xml;charset=utf8,"
        }
    }
}
