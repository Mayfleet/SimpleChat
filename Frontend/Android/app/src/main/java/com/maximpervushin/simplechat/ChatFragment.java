package com.maximpervushin.simplechat;

import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;

import java.util.Observable;
import java.util.Observer;
import java.util.Random;

/**
 * Created by maximpervushin on 23/03/16.
 */
public class ChatFragment extends Fragment implements Observer, View.OnClickListener {

    private EditText messageEditText;
    private MessagesAdapter adapter;
    private Chat chat;
    private String senderId;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.chat_fragment, container, false);

        senderId = "Android Client #" + (new Random()).nextInt(1000);

        adapter = new MessagesAdapter(getActivity(), senderId);

        ListView listView = (ListView) view.findViewById(R.id.messagesListView);
        listView.setAdapter(adapter);

        messageEditText = (EditText) view.findViewById(R.id.messageEditText);

        Button sendMessageButton = (Button) view.findViewById(R.id.sendMessageButton);
        sendMessageButton.setOnClickListener(this);

        chat = new Chat();
        chat.addObserver(this);
        chat.connect();

        return view;
    }

    @Override
    public void update(Observable observable, Object data) {
        if (observable instanceof Chat) {
            final ChatFragment self = this;
            getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    self.adapter.setMessages(self.chat.getMessages());
                }
            });
        }
    }

    @Override
    public void onClick(View v) {
        String text = messageEditText.getText().toString();
        if (senderId.length() == 0 || text.length() == 0) {
            return;
        }
        chat.sendMessage(new Message(senderId, text));
        messageEditText.setText("");
    }
}
