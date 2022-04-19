//
//  StandardError.swift
//  StreamDeckKit
//
//  Created by Dominik Kapusta on 19/04/2022.
//

import Foundation

public class StandardError: TextOutputStream {
  public func write(_ string: String) {
    try? FileHandle.standardError.write(contentsOf: Data(string.utf8))
  }
}
