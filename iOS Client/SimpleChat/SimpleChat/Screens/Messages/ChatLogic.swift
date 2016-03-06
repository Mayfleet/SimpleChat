//
// Created by Maxim Pervushin on 03/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON
import JSQMessagesViewController

class ChatLogic: NSObject {

    public var onChange: (Void -> Void)? {
        didSet {
            onChange?()
        }
    }

    public var server: Server? {
        didSet {
            initializeConnection()
        }
    }

    private (set) var messages = [JSQMessageData]()

    override init() {
        super.init()
        initializeConnection()
    }

    func sendText(senderId: String, text: String) {
        guard let webSocket = webSocket else {
            return
        }

        if !webSocket.isConnected {
            scheduleReconnection()
            return
        }

        guard let package = JSON(["type": "message", "senderId": senderId, "text": text]).rawString() else {
            return
        }
        print("> " + package)
        webSocket.writeString(package)
    }

    private var webSocket: WebSocket?
    private var reconnectionTimer: NSTimer?

    private func initializeConnection() {
        reconnectionTimer?.invalidate()
        reconnectionTimer = nil
        webSocket?.disconnect()
        webSocket = nil
        messages = [JSQMessageData]()
        if let server = server {
            webSocket = WebSocket(url: server.backendURL, protocols: ["http"])
            webSocket?.delegate = self
            scheduleReconnection()
        } else {
            print("ERROR: Invalid server.")
        }
        onChange?()
    }

    private func scheduleReconnection() {
        if nil == reconnectionTimer {
            reconnectionTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "reconnect", userInfo: nil, repeats: true)
            reconnectionTimer?.fire()
        }
    }

    @objc private func reconnect() {
        print("connecting...")
        webSocket?.connect()
    }

    private func processMessage(json: JSON) {
        if let messageSenderId = json["senderId"].string,
        messageSenderDisplayName = json["senderId"].string,
        messageText = json["text"].string {
            let message = JSQMessage(senderId: messageSenderId, displayName: messageSenderDisplayName, text: messageText)
            messages.append(message)
        } else {
            print("ERROR: Unable to parse message")
        }
    }

    private func processHistory(json: JSON) {
        if let messages = json["messages"].array {
            self.messages = [JSQMessageData]()
            for message in messages {
                processMessage(message)
            }
            print("messages: \(messages)")
        }
    }
}

extension ChatLogic: WebSocketDelegate {

    func websocketDidConnect(socket: WebSocket) {
        reconnectionTimer?.invalidate()
        reconnectionTimer = nil
        print("connected to: \(socket.origin)")
    }

    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("disconnected: \(error?.localizedDescription)")
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