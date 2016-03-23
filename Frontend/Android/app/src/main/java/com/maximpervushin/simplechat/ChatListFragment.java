package com.maximpervushin.simplechat;

import android.app.Activity;
import android.app.Fragment;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;

import java.util.Observable;
import java.util.Observer;

/**
 * Created by maximpervushin on 23/03/16.
 */
public class ChatListFragment extends Fragment implements Observer {

    private final String TAG = "MainActivity";
    private ChatListAdapter chatListAdapter;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.chat_list_fragment, container, false);

        chatListAdapter = new ChatListAdapter(getActivity());
        ListView listView = (ListView) view.findViewById(R.id.messagesListView);
        listView.setAdapter(chatListAdapter);
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Activity activity = getActivity();
                if (activity instanceof MainActivity) {
                    ((MainActivity) activity).showChat();
                }
            }
        });
        updateUi();

        return view;
    }

    @Override
    public void update(Observable observable, Object data) {
        if (observable instanceof ChatDispatcher) {
            final ChatListFragment self = this;
            getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    self.updateUi();
                }
            });
        }
    }

    private void updateUi() {
        chatListAdapter.setChats(ChatDispatcher.defaultDispatcher().getChats());
    }
}
