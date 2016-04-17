var App = window.App = window.App || {};

var p = App.presets = [];

p.push({
    name: 'message',
    body: {
        type: 'message',
        senderId: 'WebApp #001',
        text: 'Sample Message'
    }
});

p.push('--');

p.push({
    name: 'signup',
    body: {
        "cid": "000102030405060708090A0B0C0D0E0E",
        "type": "signup",
        "payload": {
            "username": "John Doe",
            "password": "123"
        }
    }
});

p.push({
    name: 'quick_signin',
    body: {
        "cid": "000102030405060708090A0B0C0D0E0E",
        "type": "quick_signin",
        "payload": {
            "accessToken": "12345678"
        }
    }
});

p.push({
    name: 'signin',
    body: {
        "cid": "000102030405060708090A0B0C0D0E0E",
        "type": "signin",
        "payload": {
            "username": "John Doe",
            "password": "123"
        }
    }
});