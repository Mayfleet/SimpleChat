var WebSocketServer = require('websocket').server;
var http = require('http');

module.exports.listen = function () {

    var httpServer = http.createServer();
    httpServer.listen(process.env.PORT || 3000);

    var history = [{'senderId': 'Simple Chat', 'text': 'Welcome to the Simple Chat!', 'type': 'message'}];
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
                    processMessage(connection, data);
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

    function processMessage(connection, data) {
        if (data['text'].startsWith('--command')) {
            var command = data['text'];
            if (command === '--command-help') {
                console.log("< command help");
                sendMessage(connection, {'senderId': 'Simple Chat', 'text': 'There is no help here...', 'type': 'message'});

            } else if (command == '--command-lorem') {
                console.log("< command lorem (create fake messages)");
                createMessages()

            } else {
                console.log("< unknown command: " + JSON.stringify(data));
            }

        } else {
            history.push(data);
            console.log("< message: " + JSON.stringify(data));
        }
    }

    function createMessages() {
        var messages = [
            'Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo.',
            'Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum, quia dolor sit, amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem.',
            'Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur? At vero eos et accusamus et iusto odio dignissimos ducimus, qui blanditiis praesentium voluptatum deleniti atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati cupiditate non provident, similique sunt in culpa, qui officia deserunt mollitia animi, id est laborum et dolorum fuga.',
            'Et harum quidem rerum facilis est et expedita distinctio.',
            'Nam libero tempore, cum soluta nobis est eligendi optio, cumque nihil impedit, quo minus id, quod maxime placeat, facere possimus, omnis voluptas assumenda est, omnis dolor repellendus.',
            'Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet, ut et voluptates repudiandae sint et molestiae non recusandae.',
            'Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.'
        ]

        messages.forEach(function(message) {
            var data = {'senderId': 'Simple Chat', 'text': message, 'type': 'message'}
            processMessage(null, data)
            clients.forEach(function (client) {
                sendMessage(client, data);
            });
        })
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