package com.epfl.php.testphp;

import android.app.Application;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.os.Environment;

import org.json.JSONObject;

import java.io.File;
import java.util.ArrayList;

/**
 * Created by Gasp on 07/06/16.
 */
public class MonumentApplication extends Application{
    public static final int RESULT_LOAD_IMG = 0;
    public static final int TAKE_PHOTO_CODE = 2;
    public static String dir;
    public static String fileName;
    public static String user_id = "gasp_user_id";


    @Override
    public void onCreate() {
        super.onCreate();
        // Here, we are making a folder named picFolder to store
        // pics taken by the camera using this application.
        dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES) + "/monument/";
        File newdir = new File(dir);
        newdir.mkdirs();

    }


}
