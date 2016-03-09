//
// Created by Maxim Pervushin on 03/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON

class ChatLogic: NSObject {

    var onChange: (Void -> Void)? {
        didSet {
            onChange?()
        }
    }

    var onStatusChange: ((status: String) -> Void)?

    var server: Server?

    private (set) var messages = [Message]()

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
        messages = [Message]()
        if let server = server {
            webSocket = WebSocket(url: server.backendURL, protocols: ["http"])
            webSocket?.delegate = self
            statusTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "checkConnection", userInfo: nil, repeats: true)
            statusTimer?.fire()
            checkConnection()
        }
        onChange?()
    }

    func disconnect() {
        statusTimer?.invalidate()
        statusTimer = nil
        webSocket?.disconnect()
        webSocket = nil
        messages = [Message]()
        onChange?()
    }

    private var webSocket: WebSocket?
    private var statusTimer: NSTimer?

    @objc private func checkConnection() {
        if let webSocket = webSocket where !webSocket.isConnected {
            onStatusChange?(status: "Offline")
            print("Connection: offline. reconnecting...")
            webSocket.connect()
        } else {
            onStatusChange?(status: "Online")
            print("Connection: online.")
        }
    }

    private func processMessage(json: JSON) {
        if let messageSender = json["senderId"].string,
        messageText = json["text"].string {
            // TODO: Parse date
            let message = Message(sender: messageSender, text: messageText, date: NSDate())
            print("timeIntervalSince1970: \(NSDate().timeIntervalSince1970)")
            messages.append(message)
        } else {
            print("ERROR: Unable to parse message")
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
}

extension ChatLogic: WebSocketDelegate {

    func websocketDidConnect(socket: WebSocket) {
        print("Connected to: \(socket.origin)")
        onStatusChange?(status: "Online")
    }

    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("Disconnected from: \(socket.origin). Error: \(error?.localizedDescription)")
        onStatusChange?(status: "Offline")
    }

    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let json = JSON.parse(text)

        switch json["type"] {
        case "history":
            processHistory(json)
            onChange?()
            break
        case "message":
            processMessage(json)
            onChange?()
            break
        default:
            print("< unknown message: \(json)")
            break
        }
    }

    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
    }
}