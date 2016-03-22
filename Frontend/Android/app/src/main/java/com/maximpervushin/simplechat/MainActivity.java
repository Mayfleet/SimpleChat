package com.maximpervushin.simplechat;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;

import java.util.Observable;
import java.util.Observer;
import java.util.Random;

public class MainActivity extends AppCompatActivity implements Observer, View.OnClickListener {

    private final String TAG = "MainActivity";
    private EditText messageEditText;
    private MessagesAdapter adapter;
    private Chat chat;
    private String senderId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        senderId = "Android Client #" + (new Random()).nextInt(1000);
        adapter = new MessagesAdapter(this, senderId);

        ListView listView = (ListView) findViewById(R.id.messagesListView);
        listView.setAdapter(adapter);

        messageEditText = (EditText) findViewById(R.id.messageEditText);

        Button sendMessageButton = (Button) findViewById(R.id.sendMessageButton);
        sendMessageButton.setOnClickListener(this);

        chat = new Chat();
        chat.addObserver(this);
        chat.connect();
    }

    @Override
    public void update(Observable observable, Object data) {
        if (observable instanceof Chat) {
            final MainActivity self = this;
            runOnUiThread(new Runnable() {
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
