var http = require('http');
var fs = require('fs');

var server = http.createServer(function (request, response) {
    response.writeHeader(200, {'Content-Type': 'text/html'});
    fs.readFile('./index.html', function (err, html) {
        response.write(html);
        response.end();
    });
});

server.listen(8080);
