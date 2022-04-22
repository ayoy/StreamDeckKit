//
//  StreamDeckKitTests.swift
//  StreamDeckKit
//
//  Created by Dominik Kapusta on 19/04/2022.
//

import XCTest
@testable import StreamDeckKit

final class StreamDeckKitTests: XCTestCase {

    func testPluginPath() throws {
        XCTAssertEqual(
            URL(fileURLWithPath: "/Users/john/path.sdPlugin/comes.txt/here.app/foo.bin").pluginPath,
            "/Users/john/path.sdPlugin"
        )

        XCTAssertNil(URL(fileURLWithPath: "/").pluginPath)
        XCTAssertNil(URL(fileURLWithPath: "/plugin.sdPlugin/../etc/passwd").pluginPath)
        XCTAssertNil(URL(fileURLWithPath: "/sdPlugin/file.txt").pluginPath)

        XCTAssertEqual(URL(fileURLWithPath: "/plugin.sdPlugin").pluginPath, "/plugin.sdPlugin")
        XCTAssertEqual(URL(fileURLWithPath: "/plugin.sdPlugin/x").pluginPath, "/plugin.sdPlugin")
    }

    func testCommandLineParametersDictionary() throws {

        let parametersString = "-port 1000 -pluginUUID ABCD0123 -registerEvent abc.abcd -info {}"
        let parametersArray = parametersString.split(separator: " ").map(String.init)
        let parametersDict = try parametersArray.commandLineParametersDictionary()

        XCTAssertEqual(
            parametersDict,
            [
                "-port": "1000",
                "-pluginUUID": "ABCD0123",
                "-registerEvent": "abc.abcd",
                "-info": "{}"
            ]
        )
    }
}
