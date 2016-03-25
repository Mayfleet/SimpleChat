package com.maximpervushin.simplechat;

import java.util.ArrayList;
import java.util.List;
import java.util.Observable;

/**
 * Created by maximpervushin on 23/03/16.
 */
public class ChatDispatcher extends Observable {

    private List<Chat> chats = new ArrayList<>();

    private static ChatDispatcher defaultDispatcher;

    static {
        defaultDispatcher = new ChatDispatcher();
    }

    private ChatDispatcher() {
        chats.add(new Chat("Localhost:3000", "ws://10.0.2.2:3000"));
        chats.add(new Chat("Heroku", "ws://mf-simple-chat.herokuapp.com:80/"));
    }

    public static ChatDispatcher defaultDispatcher() {
        return defaultDispatcher;
    }

    public List<Chat> getChats() {
        return chats;
    }

    public Chat getChat(String identifier) {
        for (Chat chat: chats) {
            if (identifier.equals(chat.getIdentifier())) {
                return chat;
            }
        }
        return null;
    }
}
