package com.epfl.php.testphp;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

public class FirstActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_first);
    }

    public void goToMainActivity(View view) {
        EditText user_id = (EditText) findViewById(R.id.user_id);
        String id  = user_id.getText().toString();
        if(user_id.equals("")){
            Toast.makeText(this,"enter a valid id",Toast.LENGTH_SHORT).show();
        }
        else{
            MonumentApplication.user_id = id;
            startActivity(new Intent(this,MainActivity.class));
        }
    }
}
