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
public class LogInFragment extends Fragment {

    private final String TAG = "SignUpFragment";

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.log_in_fragment, container, false);
        final EditText usernameEditText = (EditText)view.findViewById(R.id.username_edit_text);
        final EditText passwordEditText = (EditText)view.findViewById(R.id.password_edit_text);
        Button logInButton = (Button)view.findViewById(R.id.log_in_button);
        logInButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.d(TAG, "Log in with username: " + usernameEditText.getText() + ", password: " + passwordEditText.getText());
            }
        });
        Button resetPasswordButton = (Button)view.findViewById(R.id.reset_password_button);
        resetPasswordButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.d(TAG, "Reset password for username: " + usernameEditText.getText());
            }
        });
        Button showSignUpButton = (Button)view.findViewById(R.id.show_sign_up_button);
        showSignUpButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.d(TAG, "Show sign up");
            }
        });
        return view;
    }
}
