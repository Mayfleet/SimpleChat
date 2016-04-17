var App = window.App = window.App || {};

$(function() { App.init(); });

App.init = function () {
    App.initUi();
    App.initSocket();
};

App.initUi = function () {
    App.$display = $('.x-incoming-display').first();
    App.$outgoingEdit = $('.x-outgoing-section .x-textarea-container textarea').first();
    App.$presetButton = $('.x-preset-button');
    App.$presetMenu = $('.x-preset-menu');

    $('.x-send-button').on('click', function () {
        App.sendFromEdit();
    });

    var presets = App.presets || [];

    App.presetIndex = {};

    $.each(presets, function (index, preset) {
        if (preset === '--') {
            App.$presetMenu.append($('<li/>', {
                role: 'separator',
                'class': 'divider'
            }));
        } else {
            var name = preset.name;
            App.presetIndex[name] = preset.body;
            App.$presetMenu.append($('<li/>').append($('<a/>', {
                text: name,
                href: '#',
                'class': 'x-preset-item',
                'data-name': name
            })));
        }
    });

    $('.x-preset-item').click(function (e) {
        var name = $(this).data('name');
        var presetBody = App.presetIndex[name];

        if ($.isPlainObject(presetBody)) {
            try {
                presetBody = JSON.stringify(presetBody, null, 2);
            } catch (e) {
                // ignore
            }
        }

        App.$outgoingEdit.val(presetBody);
        App.$outgoingEdit.focus();

        e.preventDefault();
    });

    $(window).keypress(function(event) {
        if (event.which === 12 && event.ctrlKey) {
            App.$presetButton.dropdown('toggle');
            setTimeout(function () {
                console.log('II', App.$presetMenu.children('.x-preset-item a').first().focus);
                App.$presetMenu.children('.x-preset-item').first().focus();
            }, 2000);

            event.preventDefault();
            return false;
        }

        if (event.which === 13 && event.ctrlKey) {
            App.sendFromEdit();
            event.preventDefault();
            return false;
        }

        return true;
    });

};

App.initSocket = function () {

    var backendUrl = App._getHashValue('server') || 'ws://localhost:3000/';

    var socket = App.socket = new WebSocket(backendUrl);

    socket.onopen = function () {
        App.logMessage('Connection opened.', 'service');
    };

    socket.onclose = function (event) {
        if (event.wasClean) {
            App.logMessage('Connection closed.', 'service');
        } else {
            App.logMessage('Connection broken.', 'service');
        }
    };

    socket.onerror = function (error) {
        App.logMessage('Connection error: ' + error.message, 'service');
    };

    socket.onmessage = function (event) {
        try {
            var obj = JSON.parse(event.data);
            var str = JSON.stringify(obj, null, 2);
            App.logMessage(str, 'incoming');
        } catch (e) {
            App.logMessage(event.data, 'incoming');
        }
    };
};

App.sendPacket = function (data) {
    App.socket.send(data);
    App.logMessage(data, 'outgoing');
};

App.logMessage = function (text, type) {
    type = type || 'response';

    var dstEl = App.$display;

    dstEl.children('.x-message').removeClass('last');

    var el = $('<div/>', {
        'class': 'x-message last',
        text: text
    });

    var prefix = '';
    if (type === 'incoming') {
        prefix = 'IN ';
        el.addClass('incoming')
    } else
    if (type === 'outgoing') {
        prefix = 'OUT ';
        el.addClass('outgoing')
    }

    (type === 'service') && (el.addClass('service'));

    var timestamp = moment().format('HH:mm:ss.SS');
    var label = prefix + timestamp;

    $('<b/>', { text: label }).appendTo(el);

    el.appendTo(dstEl);

    dstEl.animate({ scrollTop: dstEl.prop('scrollHeight')}, 0);
};

App.sendFromEdit = function () {
    var data = App.$outgoingEdit.val();
    App.sendPacket(data);
};

App._getHashValue = function (key) {
    var matches = location.hash.match(new RegExp(key + '=([^&]*)'));
    return matches ? matches[1] : null;
};