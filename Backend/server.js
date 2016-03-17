var WebSocketServer = require('websocket').server;
var http = require('http');
var fs = require('fs');

module.exports.listen = function () {

    var httpServer = http.createServer();
    httpServer.listen(process.env.PORT || 3000);

    var history = [{'senderId': 'Admin', 'text': 'Welcome to the Simple Chat!', 'type': 'message'}];
    var clients = [];

    var wsServer = new WebSocketServer({
        httpServer: httpServer
    });

    wsServer.on('request', function (request) {
        var connection = request.accept(null, request.origin);

        console.log((new Date()) + ' Connection accepted.');

        clients.push(connection);
        sendHistory(connection);

        connection.on('message', function (message) {
            if (message.type === 'utf8') {
                var data = JSON.parse(message.utf8Data);
                if (data['type'] == 'authentication') {
                    processAuthentication(connection, data)
                } else if (data['type'] == 'message') {
                    processMessage(data);
                    clients.forEach(function (client) {
                        sendMessage(client, data);
                        sendDebugReport(client);
                    });
                }
            }
        });

        connection.on('close', function (connection) {
            clients.splice(clients.indexOf(connection), 1);
            console.log((new Date()) + ' Connection closed.');
        });
    });

    function processAuthentication(client, data) {
        // clients.push(client);
        // console.log("+ authentication: " + client + ' + ' + data);
        // console.log("* clients: " + clients);
    }

    function processMessage(data) {
        history.push(data);
        console.log("< message: " + JSON.stringify(data));
    }

    function sendMessage(client, data) {
        client.sendUTF(JSON.stringify(data));
    }

    function sendDebugReport(client) {
        // var debugReport = {
        //     'type': 'message',
        //     'senderId': 'Server',
        //     'text': 'users: ' + clients.length + ', messages: ' + history.length
        // };
        // client.sendUTF(JSON.stringify(debugReport));
    }

    function sendHistory(client) {
        if (history.length > 0) {
            var container = {'type': 'history', 'messages': history};
            client.sendUTF(JSON.stringify(container));
        }
    }
};