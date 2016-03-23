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
        chats.add(new Chat());
        chats.add(new Chat());
        chats.add(new Chat());
        chats.add(new Chat());
        chats.add(new Chat());
    }

    public static ChatDispatcher defaultDispatcher() {
        return defaultDispatcher;
    }

    public List<Chat> getChats() {
        return chats;
    }
}
