package com.maximpervushin.simplechat;

import android.app.FragmentTransaction;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;

public class ChatListActivity extends AppCompatActivity {

    private final String TAG = "ChatListActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.chat_list_activity);
    }

    public void showChat(Chat chat) {
        Intent intent = new Intent();
        intent.setClass(this, ChatActivity.class);
        // TODO: putExtra with chat identifier
        startActivity(intent);
        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }
}
