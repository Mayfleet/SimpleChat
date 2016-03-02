var WebSocketServer = require('websocket').server;
var http = require('http');

var server = http.createServer(function(request, response) {
    response.writeHeader(200, { 'Content-Type': 'text/html' });
    require('fs').readFile('./index.html', function(err, html) {
        response.write(html);
        response.end();
    });
});
server.listen(3000, function() {});

wsServer = new WebSocketServer({
    httpServer: server
});

var history = ['hello world', 'this is simple chat']
var clients = []

wsServer.on('request', function(request) {
    var connection = request.accept(null, request.origin);

    clients.push(connection)

    console.log((new Date()) + ' Connection accepted.');

    if (history.length > 0) {
        connection.sendUTF(JSON.stringify({ type: 'history', data: history }));
    }

    connection.on('message', function(message) {
        if (message.type === 'utf8') {
            console.log('<- ' + message.utf8Data)
            history.push(message.utf8Data)
            clients.forEach(function(client) {
                client.sendUTF(JSON.stringify({ type: 'message', data: message.utf8Data }))
            });
        }
    });

    connection.on('close', function(connection) {
        clients.splice(clients.indexOf(connection), 1)
        console.log((new Date()) + ' Connection closed.');
    });
});
