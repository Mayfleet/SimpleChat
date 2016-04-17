package com.maximpervushin.simplechat;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by maximpervushin on 23/03/16.
 */
public class ChatListAdapter extends BaseAdapter {

    private Context context;
    private List<Chat> chats = new ArrayList<>();

    public ChatListAdapter(Context context) {
        this.context = context;
    }

    @Override
    public int getCount() {
        return chats.size();
    }

    @Override
    public Object getItem(int position) {
        return chats.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View itemView = convertView;
        if (null == itemView) {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            itemView = inflater.inflate(R.layout.chat_item_layout, parent, false);
        }

        Chat chat = (Chat) getItem(position);

        TextView textView1 = (TextView) itemView.findViewById(R.id.chat_name_text);
        textView1.setText(chat.getName());
        TextView textView2 = (TextView) itemView.findViewById(R.id.chat_backend_text);
        textView2.setText(chat.getBackendURIString());

        return itemView;
    }

    public void setChats(List<Chat> chats) {
        this.chats = chats;
        notifyDataSetInvalidated();
    }
}
