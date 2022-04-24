//
//  Constants.swift
//  StreamDeckKit
//
//  Created by Dominik Kapusta on 19/04/2022.
//

import Foundation

public enum Target: Int32, Codable {
    case hardwareAndSoftware = 0
    case hardwareOnly = 1
    case softwareOnly = 2
}

public enum DeviceType: Int32, Codable {
    case streamDeck = 0
    case streamDeckMini = 1
    case streamDeckXL = 2
    case streamDeckMobile = 3
}

public extension ExpressibleByIntegerLiteral {
    static var sdkVersion: Self { 2 }
}

extension String {

    enum ESD {

        // MARK: - Common base-interface

        static let commonAction = "action"
        static let commonEvent = "event"
        static let commonContext = "context"
        static let commonPayload = "payload"
        static let commonDevice = "device"
        static let commonDeviceInfo = "deviceInfo"

        // MARK: - Events

        static let eventKeyDown = "keyDown"
        static let eventKeyUp = "keyUp"
        static let eventWillAppear = "willAppear"
        static let eventWillDisappear = "willDisappear"
        static let eventDeviceDidConnect = "deviceDidConnect"
        static let eventDeviceDidDisconnect = "deviceDidDisconnect"
        static let eventApplicationDidLaunch = "applicationDidLaunch"
        static let eventApplicationDidTerminate = "applicationDidTerminate"
        static let eventSystemDidWakeUp = "systemDidWakeUp"
        static let eventTitleParametersDidChange = "titleParametersDidChange"
        static let eventDidReceiveSettings = "didReceiveSettings"
        static let eventDidReceiveGlobalSettings = "didReceiveGlobalSettings"
        static let eventPropertyInspectorDidAppear = "propertyInspectorDidAppear"
        static let eventPropertyInspectorDidDisappear = "propertyInspectorDidDisappear"

        // MARK: - Functions

        static let eventSetTitle = "setTitle"
        static let eventSetImage = "setImage"
        static let eventShowAlert = "showAlert"
        static let eventShowOK = "showOk"
        static let eventGetSettings = "getSettings"
        static let eventSetSettings = "setSettings"
        static let eventGetGlobalSettings = "getGlobalSettings"
        static let eventSetGlobalSettings = "setGlobalSettings"
        static let eventSetState = "setState"
        static let eventSwitchToProfile = "switchToProfile"
        static let eventSendToPropertyInspector = "sendToPropertyInspector"
        static let eventSendToPlugin = "sendToPlugin"
        static let eventOpenURL = "openUrl"
        static let eventLogMessage = "logMessage"

        // MARK: - Payloads

        static let payloadSettings = "settings"
        static let payloadCoordinates = "coordinates"
        static let payloadState = "state"
        static let payloadUserDesiredState = "userDesiredState"
        static let payloadTitle = "title"
        static let payloadTitleParameters = "titleParameters"
        static let payloadImage = "image"
        static let payloadURL = "url"
        static let payloadTarget = "target"
        static let payloadProfile = "profile"
        static let payloadApplication = "application"
        static let payloadIsInMultiAction = "isInMultiAction"
        static let payloadMessage = "message"

        static let payloadCoordinatesColumn = "column"
        static let payloadCoordinatesRow = "row"

        // MARK: - Device Info

        static let deviceInfoID = "id"
        static let deviceInfoType = "type"
        static let deviceInfoSize = "size"
        static let deviceInfoName = "name"

        static let deviceInfoSizeColumns = "columns"
        static let deviceInfoSizeRows = "rows"

        // MARK: - Title Parameters

        static let titleParametersShowTitle = "showTitle"
        static let titleParametersTitleColor = "titleColor"
        static let titleParametersTitleAlignment = "titleAlignment"
        static let titleParametersFontFamily = "fontFamily"
        static let titleParametersFontSize = "fontSize"
        static let titleParametersCustomFontSize = "customFontSize"
        static let titleParametersFontStyle = "fontStyle"
        static let titleParametersFontUnderline = "fontUnderline"

        // MARK: - Connection

        static let connectSocketFunction = "connectElgatoStreamDeckSocket"
        static let registerPlugin = "registerPlugin"
        static let registerPropertyInspector = "registerPropertyInspector"
        static let portParameter = "-port"
        static let pluginUUIDParameter = "-pluginUUID"
        static let registerEventParameter = "-registerEvent"
        static let infoParameter = "-info"
        static let registerUUID = "uuid"

        static let applicationInfo = "application"
        static let pluginInfo = "plugin"
        static let devicesInfo = "devices"
        static let colorsInfo = "colors"
        static let devicePixelRatio = "devicePixelRatio"

        static let applicationInfoVersion = "version"
        static let applicationInfoLanguage = "language"
        static let applicationInfoPlatform = "platform"

        static let applicationInfoPlatformMac = "mac"
        static let applicationInfoPlatformWindows = "windows"

        static let colorsInfoHighlightColor = "highlightColor"
        static let colorsInfoMouseDownColor = "mouseDownColor"
        static let colorsInfoDisabledColor = "disabledColor"
        static let colorsInfoButtonPressedTextColor = "buttonPressedTextColor"
        static let colorsInfoButtonPressedBackgroundColor = "buttonPressedBackgroundColor"
        static let colorsInfoButtonMouseOverBackgroundColor = "buttonMouseOverBackgroundColor"
        static let colorsInfoButtonPressedBorderColor = "buttonPressedBorderColor"

    }
}
