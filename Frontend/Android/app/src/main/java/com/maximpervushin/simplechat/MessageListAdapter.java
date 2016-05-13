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
public class MessageListAdapter extends BaseAdapter {

    private Context context;
    private String senderId;
    private List<Message> messages = new ArrayList<>();

    public MessageListAdapter(Context context, String senderId) {
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
            itemView = inflater.inflate(R.layout.message_item_layout, parent, false);
        }

        Message message = (Message) getItem(position);

        TextView senderTextView = (TextView) itemView.findViewById(R.id.message_sender);
        senderTextView.setText(message.getSender() + ":");
        TextView textTextView = (TextView) itemView.findViewById(R.id.message_text);
        textTextView.setText(message.getText());

        if (message.getSender().equals(senderId)) {
            itemView.setBackgroundColor(context.getResources().getColor(R.color.outgoingMessageBackground));
        } else {
            itemView.setBackgroundColor(context.getResources().getColor(R.color.incomingMessageBackground));
        }

        return itemView;
    }

    public void setMessages(List<Message> messages) {
        this.messages = messages;
        notifyDataSetInvalidated();
    }
}
