package com.maximpervushin.simplechat;

import android.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;

public class MainActivity extends AppCompatActivity {

    private final String TAG = "MainActivity";

    private ChatListFragment chatListFragment;
    private ChatFragment chatFragment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        View rootView = findViewById(R.id.rootView);
        rootView.setFocusableInTouchMode(true);
        rootView.requestFocus();
        rootView.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                if (KeyEvent.KEYCODE_BACK == keyCode) {
                    showChatList();
                    return true;
                } else {
                    return false;
                }
            }
        });

        showChatList();
    }

    public void showChatList() {
        FragmentTransaction fragmentTransaction = getFragmentManager().beginTransaction();
        if (null != chatFragment && chatFragment.isAdded()) {
            fragmentTransaction.remove(chatFragment);
        }
        if (null == chatListFragment) {
            chatListFragment = new ChatListFragment();
        }
        if (!chatListFragment.isAdded()) {
            fragmentTransaction.add(R.id.rootView, chatListFragment);
        }
        fragmentTransaction.commit();
    }

    public void showChat(Chat chat) {
        FragmentTransaction fragmentTransaction = getFragmentManager().beginTransaction();
        if (null != chatListFragment && chatListFragment.isAdded()) {
            fragmentTransaction.remove(chatListFragment);
        }
        if (null == chatFragment) {
            chatFragment = new ChatFragment();
        }
        chatFragment.setChat(chat);
        if (!chatFragment.isAdded()) {
            fragmentTransaction.add(R.id.rootView, chatFragment);
        }
        fragmentTransaction.commit();
    }
}
