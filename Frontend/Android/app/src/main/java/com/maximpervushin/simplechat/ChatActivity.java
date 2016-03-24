package com.maximpervushin.simplechat;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;

/**
 * Created by maximpervushin on 24/03/16.
 */
public class ChatActivity extends AppCompatActivity {

    private final String TAG = "ChatActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.chat_activity);
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        overridePendingTransition(R.anim.slide_out_right, R.anim.slide_in_left);
    }
}
