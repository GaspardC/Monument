package com.epfl.php.testphp;

import android.graphics.Bitmap;

import org.json.JSONObject;

public class PhotoEntity {
    public Bitmap bitmapImage;
    public String filename;
    public JSONObject jLoc;

    public PhotoEntity(Bitmap bitmap, String filename, JSONObject jLoc){
        this.bitmapImage = bitmap;
        this.filename = filename;
        this.jLoc = jLoc;
    }
}
