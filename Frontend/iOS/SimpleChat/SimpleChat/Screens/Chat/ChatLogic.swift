//
// Created by Maxim Pervushin on 03/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON

class ChatLogic: NSObject {

    enum Status {
        case Online
        case Offline
    }

    let configuration: ChatConfiguration
    private (set) var status = Status.Offline
    private (set) var messages = [Message]()

    init(configuration: ChatConfiguration) {
        self.configuration = configuration
    }

    convenience init?(configuration: ChatConfiguration?) {
        guard let configuration = configuration else {
            return nil
        }
        self.init(configuration: configuration)
    }

    func sendText(senderId: String, text: String) {
        guard let webSocket = webSocket else {
            return
        }

        guard let package = JSON(["type": "message", "senderId": senderId, "text": text]).rawString() else {
            return
        }
        print("> " + package)
        webSocket.writeString(package)
    }

    func connect() {
        if let webSocket = webSocket where webSocket.isConnected {
            return
        }

        messages = [Message]()
        webSocket = WebSocket(url: configuration.backendURL, protocols: ["http"])
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
            print("Connection: offline. reconnecting...")
            webSocket.connect()
        } else {
            statusChanged(Status.Online)
            print("Connection: online.")
        }
    }

    private func processMessage(json: JSON) {
        if let message = Message(dictionary: json.dictionaryObject) {
            messages.append(message)
        } else {
            print("Unable to parse message: \(json.dictionaryObject)")
        }
    }

    private func processHistory(json: JSON) {
        if let messages = json["messages"].array {
            self.messages = []
            for message in messages {
                processMessage(message)
            }
            print("messages: \(messages)")
        }
    }

    // Notifications

    static let statusChangedNotification = "ChatLogicStatusChangedNotification"
    static let messagesChangedNotification = "ChatLogicMessagesChangedNotification"

    private func statusChanged(status: Status) {
        self.status = status
        NSNotificationCenter.defaultCenter().postNotificationName(ChatLogic.statusChangedNotification, object: self)
    }


    private func messagesChanged() {
        NSNotificationCenter.defaultCenter().postNotificationName(ChatLogic.messagesChangedNotification, object: self)
    }
}

extension ChatLogic {

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

        print("> " + serialized)
        webSocket.writeString(serialized)
    }
}

extension ChatLogic: WebSocketDelegate {

    func websocketDidConnect(socket: WebSocket) {
        print("Connected to: \(socket.origin)")
        statusChanged(Status.Online)
    }

    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("Disconnected from: \(socket.origin). Error: \(error?.localizedDescription)")
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
            print("< unknown message: \(json)")
            break
        }
    }

    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
    }
}
