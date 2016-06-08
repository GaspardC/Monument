package com.epfl.php.testphp;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;

import org.json.JSONObject;

import java.util.ArrayList;

/**
 * Created by Gasp on 08/06/16.
 */
public class ListCurrentPhotos {
    public ArrayList<PhotoEntity> listPhoto;
    public Activity activity;

    public ListCurrentPhotos(Activity activity){
        listPhoto = new ArrayList<>();
        this.activity = activity;
    }

    public  void resetListPhoto(){
        listPhoto = new ArrayList<>();

        Bitmap bitmapWhite=Bitmap.createBitmap(100,100, Bitmap.Config.ARGB_8888);
        Canvas canvas=new Canvas(bitmapWhite);
        canvas.drawColor(Color.parseColor("#ffffff"));

        String pahtWhite = "no images";
        JSONObject jLoc = new JSONObject();
        listPhoto.add(new PhotoEntity(bitmapWhite,pahtWhite,jLoc));

    }


    public  PhotoEntity getPhotoEntity(int pos){
        if(pos > listPhoto.size()) return null;
        else return listPhoto.get(pos);
    }

    public void setDefautlPhotos(){
        Drawable draw1 = activity.getDrawable(R.drawable.image_1);
        Drawable draw2 = activity.getDrawable(R.drawable.image_2);
        Drawable draw3 = activity.getDrawable(R.drawable.image_3);




        assert ((BitmapDrawable) draw1) != null;
        Bitmap bit1 =((BitmapDrawable) draw1).getBitmap();
        assert ((BitmapDrawable) draw2) != null;
        Bitmap bit2 =((BitmapDrawable) draw2).getBitmap();
        assert ((BitmapDrawable) draw3) != null;
        Bitmap bit3 =((BitmapDrawable) draw3).getBitmap();

        String path1 = "path1";
        String path2 = "path2";
        String path3 = "path3";
        JSONObject jLoc1 = new JSONObject();
        JSONObject jLoc2 = new JSONObject();
        JSONObject jLoc3 = new JSONObject();





        listPhoto.add(new PhotoEntity(bit1,path1,jLoc1));
        listPhoto.add(new PhotoEntity(bit2,path2,jLoc2));
        listPhoto.add(new PhotoEntity(bit3,path3,jLoc3));

    }

}
