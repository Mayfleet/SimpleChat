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
 * Created by maximpervushin on 22/03/16.
 */
public class MessagesAdapter extends BaseAdapter {

    private Context context;
    private String senderId;
    private List<Message> messages = new ArrayList<>();

    public MessagesAdapter(Context context, String senderId) {
        this.context = context;
        this.senderId = senderId;
    }

    @Override
    public int getCount() {
        return messages.size();
    }

    @Override
    public Object getItem(int position) {
        return messages.get(position);
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
            itemView = inflater.inflate(android.R.layout.simple_list_item_1, parent, false);
        }

        Message message = (Message) getItem(position);

        TextView textView = (TextView) itemView.findViewById(android.R.id.text1);
        textView.setText(message.getText());
        if (message.getSender().equals(senderId)) {
            textView.setTextColor(context.getResources().getColor(android.R.color.holo_orange_dark));
        } else {
            textView.setTextColor(context.getResources().getColor(android.R.color.holo_blue_dark));
        }

        return itemView;
    }

    public void setMessages(List<Message> messages) {
        this.messages = messages;
        notifyDataSetInvalidated();
    }
}
