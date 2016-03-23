package com.maximpervushin.simplechat;

import android.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

public class MainActivity extends AppCompatActivity {

    private final String TAG = "MainActivity";

    private ChatListFragment chatListFragment;
    private ChatFragment chatFragment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        showChatList();
    }

    public void showChatList() {
        if (null == chatListFragment) {
            chatListFragment = new ChatListFragment();
        }
        getFragmentManager()
                .beginTransaction()
                .add(R.id.rootView, chatListFragment)
                .commit();
    }

    public void showChat() {
        FragmentTransaction fragmentTransaction = getFragmentManager().beginTransaction();
        if (null != chatListFragment) {
            fragmentTransaction.remove(chatListFragment);
        }
        if (null == chatFragment) {
            chatFragment = new ChatFragment();
        }
        fragmentTransaction.add(R.id.rootView, chatFragment);
        fragmentTransaction.commit();
    }
}
