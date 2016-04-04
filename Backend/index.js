global.rootRequire = function (name) {
    return require(__dirname + '/' + name);
};

var server = require('./server.js');
server.listen();