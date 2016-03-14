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

    var onStatusChange: ((status:String) -> Void)?

    var server: ServerConfiguration?

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
