package com.maximpervushin.simplechat;

import android.app.Fragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;

/**
 * Created by maximpervushin on 31/03/16.
 */
public class SignUpFragment extends Fragment {

    private final String TAG = "SignUpFragment";

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.sign_up_fragment, container, false);
        final EditText usernameEditText = (EditText)view.findViewById(R.id.username_edit_text);
        final EditText passwordEditText = (EditText)view.findViewById(R.id.password_edit_text);
        Button signUpButton = (Button)view.findViewById(R.id.sign_up_button);
        signUpButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.d(TAG, "Sign up with username: " + usernameEditText.getText() + ", password: " + passwordEditText.getText());
            }
        });
        return view;
    }
}
