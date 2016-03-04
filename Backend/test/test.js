'use strict'

var expect = require('chai').expect;
var server = require('../server.js');

var _ = require('lodash');
var WebSocketClient = require('websocket').client;

var testMsg = JSON.stringify({ 'senderId': 'tester', 'text': 'test message', 'type': 'message' });
var sender;
var receiver;

describe('Chat Events', function(){

    beforeEach(function(done){

        var senderClient = new WebSocketClient();
        var receiverClient = new WebSocketClient();

        var url = 'ws://127.0.0.1:5001/';

        server.listen();

        senderClient.connect(url);
        senderClient.on('connect', function (connection) {
            sender = connection;
            receiverClient.connect(url);
            receiverClient.on('connect', function (connection) {
                receiver = connection;
                done();
            });
        });
    });

    afterEach(function(done){
        sender.drop();
        receiver.drop();
        done()
    });

    describe('Message Events', function(){
        it('Clients should receive a message when the `message` event is emited.', function(done){
            sender.sendUTF(testMsg);
            receiver.on('message', function(message) {

                if (_.get(message, 'type') === 'utf8') {
                    var utf8Data = _.get(message, 'utf8Data');
                    try {
                        var data = JSON.parse(utf8Data);
                        if (_.get(data, 'type') !== 'message') return;
                    } catch (e) {
                        throw new Error('Error during parsing message');
                    }
                }

                expect(message).to.have.property('type').and.equal('utf8');
                expect(message).to.have.property('utf8Data').and.equal(testMsg);

                done()
            });
        });
    });
});