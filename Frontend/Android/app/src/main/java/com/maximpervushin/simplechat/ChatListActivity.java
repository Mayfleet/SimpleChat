package com.maximpervushin.simplechat;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

public class ChatListActivity extends AppCompatActivity {

    private final String TAG = "ChatListActivity";

    private ChatFragment chatFragment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.chat_list_activity);
        chatFragment = (ChatFragment)(getFragmentManager().findFragmentById(R.id.chat));
    }

    public void showChat(Chat chat) {
        if (null == chatFragment) {
            Intent intent = new Intent();
            intent.setClass(this, ChatActivity.class);
            intent.putExtra("chat-identifier", chat.getIdentifier());
            startActivity(intent);
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        } else {
            chatFragment.setChat(chat);
        }
    }
}
