package com.maximpervushin.simplechat;

import android.util.Log;

import org.java_websocket.client.WebSocketClient;
import org.java_websocket.exceptions.WebsocketNotConnectedException;
import org.java_websocket.handshake.ServerHandshake;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;
import java.util.Observable;

/**
 * Created by maximpervushin on 22/03/16.
 */
public class Chat extends Observable {

    private final String TAG = "Chat";
    private WebSocketClient webSocketClient;

    private List<Message> messages = new ArrayList<>();

    public List<Message> getMessages() {
        return messages;
    }

    public String getName() {
        return name;
    }

    public String getBackendURIString() {
        return backendURIString;
    }

    private String name;
    private String backendURIString;

    public Chat(String name, String backendURIString) {
        this.name = name;
        this.backendURIString = backendURIString;
    }

    public String getIdentifier() {
        return name + " -- " + backendURIString;
    }

    public void connect() {
        URI uri;
        try {
            uri = new URI(backendURIString);
        } catch (URISyntaxException e) {
            e.printStackTrace();
            return;
        }

        webSocketClient = new WebSocketClient(uri) {
            @Override
            public void onOpen(ServerHandshake handshakedata) {
                Log.d(TAG, "WS onOpen");
                changed();
            }

            @Override
            public void onMessage(String message) {
                Log.d(TAG, "WS onMessage: " + message);
                try {
                    JSONObject jsonObject = new JSONObject(message);
                    if ("history".equals(jsonObject.getString("type"))) {
                        processHistory(jsonObject);

                    } else if ("message".equals(jsonObject.getString("type"))) {
                        processMessage(jsonObject);
                    }
                } catch (JSONException e) {
                    Log.e(TAG, "Unable to parse json.");
                    e.printStackTrace();
                }
                // changed();
            }

            @Override
            public void onClose(int code, String reason, boolean remote) {
                Log.d(TAG, "WS onClose: " + reason);
                changed();
            }

            @Override
            public void onError(Exception ex) {
                Log.d(TAG, "WS onError: " + ex.getLocalizedMessage());
                changed();
            }
        };

        Log.d(TAG, "WS Created: " + webSocketClient.toString());

        webSocketClient.connect();
    }

    public void disconnect() {
        webSocketClient.close();
        webSocketClient = null;
    }

    public void sendMessage(Message message) {
        try {
            JSONObject messageObject = new JSONObject();
            messageObject.put("type", "message");
            messageObject.put("senderId", message.getSender());
            messageObject.put("text", message.getText());
            String messageString = messageObject.toString();
            webSocketClient.send(messageString);
        } catch (JSONException | WebsocketNotConnectedException e) {
            e.printStackTrace();
        }
    }

    private void changed() {
        setChanged();
        notifyObservers(this);
    }

    private void processHistory(JSONObject jsonObject) {
        this.messages.clear();
        try {
            JSONArray messages = jsonObject.getJSONArray("messages");
            for (int i = 0; i < messages.length(); ++i) {
                JSONObject messageObject = messages.getJSONObject(i);

                Message message = new Message(messageObject.getString("senderId"), messageObject.getString("text"));
                Log.v(TAG, "< history message: " + message);
                this.messages.add(message);
            }
        } catch (JSONException e) {
            Log.e(TAG, "Unable to process history");
            e.printStackTrace();
        }

        changed();
    }

    private void processMessage(JSONObject jsonObject) {
        try {
            Message message = new Message(jsonObject.getString("senderId"), jsonObject.getString("text"));
            messages.add(message);
            Log.v(TAG, "< message: " + message);

        } catch (JSONException e) {
            Log.e(TAG, "Unable to process message");
            e.printStackTrace();
        }

        changed();
    }
}
