global.rootRequire = function (name) {
    return require(__dirname + '/' + name);
};

var _ = require('lodash');

global.colors = require('colors/safe');

var Server = rootRequire('app/server');

var server = new Server({
    host: process.env.HOST || '127.0.0.1',
    port: process.env.PORT || 3000,
    backlog: 128
});

server.listen(function (err) {
    if (err) {
        console.error('Failure during server startup.');
        return;
    }
    var serverConfig = server.getConfig();
    try {
        serverConfig = JSON.stringify(serverConfig, null, 2);
    } catch (e) {
        serverConfig = serverConfig || 'NO CONFIGURATION';
    }
    console.log('Server successfully started with the following configuration:\n' + serverConfig);
});

process.on('uncaughtException', function(err) {
    // Log event
    console.error(colors.red('Caught exception: ', err.stack));
    // Release resources
    server.release();
    process.exit(0);
});

setTimeout(function () {
    callMMM();
}, 3000);