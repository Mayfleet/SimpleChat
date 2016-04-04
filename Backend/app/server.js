var _ = require('lodash');
var http = require('http');
var WebSocketServer = require('websocket').server;

function Server (config) {
    var me = this;

    me._host = _.get(config, 'host', '127.0.0.1');
    me._port = _.get(config, 'port', 3000);
    me._backlog = _.get(config, 'backlog');

    me._connections = [];

    me._httpServer = http.createServer();

    me._wsServer = new WebSocketServer({ httpServer: me._httpServer });
    me._wsServer.on('request', me._handleRequest);
}

module.exports = Server;

Server.prototype._originIsAllowed = function (origin) {
    // TODO: Put logic here to detect whether the specified origin is allowed.
    return true;
};

Server.prototype._handleRequest = function (request) {
    var me = this;

    if (!me._originIsAllowed(request.origin)) {
        // Make sure we only accept requests from an allowed origin
        request.reject();
        console.log((new Date()) + ' Connection from origin ' + request.origin + ' rejected.');
        return;
    }

    var connection = request.accept(null, request.origin);

    console.log((new Date()) + ' Connection accepted.');

    me._connections.push(connection);

    connection.on('message', function (message) {
        if (message.type === 'utf8') {
            try {
                var data = JSON.parse(message.utf8Data);
                // TODO: Parse package object and call appropriate handler
                console.log('PACKAGE', data);
            } catch (e) {
                // Ignore non-json packages
            }
        }
    });

    connection.on('close', function (connection) {
        me._connections.splice(me._connections.indexOf(connection), 1);
        console.log((new Date()) + ' Connection closed.');
    });
};

Server.prototype.listen = function () {
    var me = this;
    me._httpServer.listen(me._port, me._host, me._backlog);
};