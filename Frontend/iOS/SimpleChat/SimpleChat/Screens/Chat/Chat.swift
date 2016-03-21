//
// Created by Maxim Pervushin on 03/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON
import CocoaLumberjack

class Chat: NSObject {

    enum Status {
        case Online
        case Offline
    }

    var name: String
    var backendURL: NSURL
    var autoconnect: Bool

    private (set) var authenticationRequired: Bool = false
    private (set) var status = Status.Offline
    private (set) var messages = [Message]()

    init(name: String, backendURL: NSURL, autoconnect: Bool = false) {
        self.name = name
        self.backendURL = backendURL
        self.autoconnect = autoconnect
    }

    convenience init?(name: String?, backendURLString: String?, autoconnect: Bool = false) {
        guard let name = name, backendURLString = backendURLString, backendURL = NSURL(string: backendURLString) else {
            return nil
        }
        self.init(name: name, backendURL: backendURL, autoconnect: autoconnect)
    }

    func sendText(senderId: String, text: String) {
        guard let webSocket = webSocket else {
            return
        }

        guard let package = JSON(["type": "message", "senderId": senderId, "text": text]).rawString() else {
            return
        }
        webSocket.writeString(package)
        DDLogDebug("> " + package)
    }

    func sendSignIn(signIn: SigninRequest) {
        guard let webSocket = webSocket else {
            return
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 2)), dispatch_get_main_queue(), {
            self.authenticationChanged(false)
        })
    }

    func connect() {
        if let webSocket = webSocket where webSocket.isConnected {
            return
        }

        messages = [Message]()
        webSocket = WebSocket(url: backendURL, protocols: ["http"])
        webSocket?.delegate = self
        statusTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "checkConnection", userInfo: nil, repeats: true)
        statusTimer?.fire()
        checkConnection()
        messagesChanged()
    }

    func disconnect() {
        statusTimer?.invalidate()
        statusTimer = nil
        webSocket?.disconnect()
        webSocket = nil
        messages = [Message]()
        messagesChanged()
    }

    private var webSocket: WebSocket?
    private var statusTimer: NSTimer?

    @objc private func checkConnection() {
        if let webSocket = webSocket where !webSocket.isConnected {
            statusChanged(Status.Offline)
            webSocket.connect()
        } else {
            statusChanged(Status.Online)
        }
    }

    private func processMessage(json: JSON) {
        if let message = Message(dictionary: json.dictionaryObject) {
            messages.append(message)
        } else {
            DDLogError("Unable to parse message: \(json.dictionaryObject)")
        }
    }

    private func processHistory(json: JSON) {
        if let messages = json["messages"].array {
            self.messages = []
            for message in messages {
                processMessage(message)
            }
            DDLogDebug("messages: \(messages)")
        }
    }

    // MARK: Notifications

    static let authenticationChangedNotification = "ChatAuthenticationChangedNotification"
    static let statusChangedNotification = "ChatStatusChangedNotification"
    static let messagesChangedNotification = "ChatMessagesChangedNotification"

    private func authenticationChanged(authenticationRequired: Bool) {
        self.authenticationRequired = authenticationRequired
        NSNotificationCenter.defaultCenter().postNotificationName(Chat.authenticationChangedNotification, object: self)
    }

    private func statusChanged(status: Status) {
        self.status = status
        NSNotificationCenter.defaultCenter().postNotificationName(Chat.statusChangedNotification, object: self)
    }

    private func messagesChanged() {
        NSNotificationCenter.defaultCenter().postNotificationName(Chat.messagesChangedNotification, object: self)
    }

    // MARK: Debug

    func debug_setAuthenticationRequired(authenticationRequired: Bool) {
        authenticationChanged(authenticationRequired)
    }
}

extension Chat {

    private func sendRequest(request: Request) {
        guard let webSocket = webSocket else {
            return
        }

        let dictionary = [
                "cid": request.cid,
                "type": request.type,
                "payload": request.payload
        ]

        guard let serialized = JSON(dictionary).rawString() else {
            return
        }

        webSocket.writeString(serialized)
        DDLogDebug("> " + serialized)
    }
}

extension Chat: WebSocketDelegate {

    func websocketDidConnect(socket: WebSocket) {
        statusChanged(Status.Online)
    }

    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        statusChanged(Status.Offline)
    }

    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let json = JSON.parse(text)

        switch json["type"] {
        case "history":
            processHistory(json)
            messagesChanged()
            break
        case "message":
            processMessage(json)
            messagesChanged()
            break
        default:
            DDLogError("< unknown message: \(json)")
            break
        }
    }

    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
    }
}
