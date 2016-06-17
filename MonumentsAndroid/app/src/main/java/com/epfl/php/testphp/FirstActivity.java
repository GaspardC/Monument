package com.epfl.php.testphp;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

public class  FirstActivity extends AppCompatActivity {

    private static final int REQUEST_CAMERA = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_first);


        int permissionCameraCheck = ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA);
        int permissionWriteCheck = ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE);
        int permissionInternetCheck = ContextCompat.checkSelfPermission(this, Manifest.permission.INTERNET);
        int permissionFineLocationCheck = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION);


        if(permissionCameraCheck != PackageManager.PERMISSION_GRANTED){
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA}, REQUEST_CAMERA);
        }
        if(permissionCameraCheck != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, 1);
        }
        if(permissionCameraCheck != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.INTERNET}, 2);
        }
        if(permissionCameraCheck != PackageManager.PERMISSION_GRANTED){
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, 3);
        }


    }


    public void goToMainActivity(View view) {
        EditText user_id = (EditText) findViewById(R.id.user_id);
        String id  = user_id.getText().toString();
        if(user_id.equals("")){
            Toast.makeText(this,"enter a valid id",Toast.LENGTH_SHORT).show();
        }
        else{
            MonumentApplication.user_id = id;
            startActivity(new Intent(this,UploadActivity.class));
        }
    }

    public void goToDisplayActivity(View view) {
        startActivity(new Intent(this,Obj3DView.class));

    }

    public void goToTriangleActivity(View view) {
        startActivity(new Intent(this,TriangleActivity.class));

    }
}
