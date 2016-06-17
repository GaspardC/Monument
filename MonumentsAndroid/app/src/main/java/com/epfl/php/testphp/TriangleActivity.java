package com.epfl.php.testphp;

import android.graphics.Matrix;
import android.opengl.GLSurfaceView;
import android.opengl.GLU;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Toast;


import com.google.common.io.ByteStreams;

import org.apache.commons.codec.binary.Hex;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Iterator;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

public class TriangleActivity extends AppCompatActivity {

    private GLSurfaceView glView;
    private Triangle		triangle1;
    private Triangle		triangle2;
    private Square square;
    private Point point;
    private Point point2;
    private MyOpenGLRenderer mRenderer;
    private float mPreviousX;
    private float mPreviousY;
    private float mDensity;
    public float scale = 1f;
    private boolean isBeingDrawn = false;


    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);

        final DisplayMetrics displayMetrics = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
        mDensity = displayMetrics.density;

        glView = new GLSurfaceView(this);

        new Thread(new Runnable() {
            @Override
            public void run() {

                try {
                    //creating new thread to handle Http Operations
                    readFileFromServer();

                } catch (OutOfMemoryError e) {

                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(TriangleActivity.this, "Insufficient Memory!", Toast.LENGTH_SHORT).show();
                        }
                    });

                }
            }
        }).start();

        ArrayList<Point> listPoint = new ArrayList<>();
//        for (int i = 0; i<300;i++){
//            float x = (float) (2.0f * Math.random() -1.0f) ;
//            float y = (float) (2.0f * Math.random() -1.0f) ;
//            float z = (float) (2.0f * Math.random() -1.0f) ;
//
//            float red = (float) Math.random();
//            float green = (float) Math.random();
//            float blue = (float) Math.random();
//            float alpha = (float) Math.random();
//            listPoint.add(new Point(x,y,z,red,green,blue,alpha));
//
//        }
        mRenderer = new MyOpenGLRenderer(listPoint);
        glView.setRenderer(mRenderer);
        setContentView(glView);
        /* Using it */
        final ScaleGestureDetector mScaleDetector =
                new ScaleGestureDetector(this, new MyPinchListener(this));

        glView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {

                mScaleDetector.onTouchEvent(event);

                if (event != null)
                {
                    float x = event.getX();
                    float y = event.getY();

                    if (event.getAction() == MotionEvent.ACTION_MOVE)
                    {
                        if (mRenderer != null)
                        {
                            float deltaX = (x - mPreviousX) / mDensity / 200f;
                            float deltaY = (y - mPreviousY) / mDensity / 200f;

                            mRenderer.mDeltaX += deltaX;
                            mRenderer.mDeltaY += deltaY;

                            Log.d("gggg", String.valueOf(deltaX) + String.valueOf(deltaY));
                        }
                    }

                    mPreviousX = x;
                    mPreviousY = y;

                    return true;
                }
                return false;
            }
        });




    }

    private void readFileFromServer() {
        try {
            // Create a URL for the desired page
            URL url = new URL("http://dhlabsrv4.epfl.ch/wtm/get.php?f=venezia-gesuati&s=6136209");



            InputStream in = url.openStream();
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            byte[] read = new byte[4096];
            final ArrayList<Point> listPoint = new ArrayList<>();

            int len;
            while((len = in.read(read)) > -1) {
               for(int i = 0; i<len;i++){
                   if (i%16 == 0){



                      //float f = ByteBuffer.wrap(read,i,8).getFloat();
                      float x = ByteBuffer.wrap(read,i,8).order(ByteOrder.LITTLE_ENDIAN).getFloat();
                      float y = ByteBuffer.wrap(read,i+4,8).order(ByteOrder.LITTLE_ENDIAN).getFloat();
                      float z = ByteBuffer.wrap(read,i+8,8).order(ByteOrder.LITTLE_ENDIAN).getFloat();

                       String r = Integer.toHexString(read[i+12]);
                       if(r.length()>2)
                           r = r.substring(r.length()-2,r.length());
                       int red = Integer.parseInt(r,16);
                       String g = Integer.toHexString(read[i+13]);
                       if(g.length()>2)
                           g = g.substring(g.length()-2,g.length());
                       int green = Integer.parseInt(g,16);
                       String b = Integer.toHexString(read[i+14]);
                       if(b.length()>2)
                           b = b.substring(b.length()-2,b.length());
                       int blue = Integer.parseInt(b,16);

                       String a = Integer.toHexString(read[i+15]);
                       if(a.length()>2)
                           a = a.substring(a.length()-2,a.length());
                       int alpha = Integer.parseInt(a,16);
//                       Log.d("mCouleur", String.valueOf(red) + " " + String.valueOf(green) + " " + String.valueOf(blue));


                       listPoint.add(new Point(x,y,z,(float) red,(float) green,(float ) blue, ( float) alpha));
//                       listPoint.add(new Point(x,y,z,1.0f,0.0f,0.0f, 0.5f));

                       if ((i%50000) == 0){
                           runOnUiThread(new Runnable() {
                               @Override
                               public void run() {
                                   updateAndDraw(listPoint);

                               }
                           });
                       }


                   }
               }


            }

            // this is the final byte array which contains the data
            // read from Socket
            byte[] bytes = baos.toByteArray();
        } catch (MalformedURLException e) {
        } catch (IOException e) {
        }
    }

    private void updateAndDraw(ArrayList<Point> listPoint) {
        if (!isBeingDrawn) {
            Log.d("mCurrentTAG", "update size " + listPoint.size());

            mRenderer.listPoints = (ArrayList<Point>) listPoint.clone();
        }

    }

    static class MyPinchListener extends ScaleGestureDetector.SimpleOnScaleGestureListener {

        private TriangleActivity activity;

        public MyPinchListener(TriangleActivity triangleActivity) {
            activity = triangleActivity;
        }

         public boolean onScale(ScaleGestureDetector detector) {
            Log.d("TAG", "PINCH! OUCH!" + String.valueOf(detector.getScaleFactor()));
            activity.scale *=  detector.getScaleFactor();
            return true;
        }
    }


    private class MyOpenGLRenderer implements GLSurfaceView.Renderer {

        public float mDeltaX;
        public float mDeltaY;
        public ArrayList<Point> listPoints;
        public ArrayList<Point> newListPoints;

        public MyOpenGLRenderer(ArrayList<Point> listPoint) {
            this.listPoints = listPoint;
        }

        @Override
        public void onSurfaceChanged(GL10 gl, int width, int height) {
            Log.d("MyOpenGLRenderer", "Surface changed. Width=" + width
                    + " Height=" + height);
            triangle1 = new Triangle(0.5f, 1, 0, 0);
            triangle2 = new Triangle(0.5f, 0, 1, 0);
            gl.glViewport(0, 0, width, height);
            gl.glMatrixMode(GL10.GL_PROJECTION);
            gl.glLoadIdentity();
            GLU.gluPerspective(gl, 45.0f, (float) width / (float) height,
                    0.1f, 100.0f);
            gl.glMatrixMode(GL10.GL_MODELVIEW);
            gl.glLoadIdentity();

            square = new Square();
            point = new Point( -0.50f,  1.0f, 0.0f, 1.0f,0.0f,0.0f,0.5f);
            point2 = new Point(-0.0f, 0.50f, 1.5f, 0.0f, 0.0f, 1.0f,0.5f);

        }

        @Override
        public void onSurfaceCreated(GL10 gl, EGLConfig config) {
            Log.d("MyOpenGLRenderer", "Surface created");
        }


        @Override
        public void onDrawFrame(GL10 gl) {
//            gl.glClearColor(0.0f, 0.0f, 0.0f, 1f);
//            gl.glClear(GL10.GL_COLOR_BUFFER_BIT);
//            gl.glLoadIdentity();
//            gl.glTranslatef(0.0f, 0.0f, -5.0f);
//            triangle1.draw(gl);
//            gl.glTranslatef(2.0f, 0.0f, -5.0f);
//            triangle2.draw(gl);

            // Clears the screen and depth buffer.
            gl.glClear(GL10.GL_COLOR_BUFFER_BIT |
                    GL10.GL_DEPTH_BUFFER_BIT);

            // Draw our square.
            gl.glLoadIdentity();
            gl.glTranslatef(mDeltaX, -mDeltaY, -5 + scale);
//            deltaX = 0;
//            deltaY = 0;
//            square.draw(gl); // ( NEW )
//            point.draw(gl);
//            point2.draw(gl);

            if(listPoints == null || listPoints.size() == 0) return;
            isBeingDrawn = true;
            Log.d("mCurrentTAG", "drawTrue size " + listPoints.size());

            Iterator<Point> pointIterator = listPoints.iterator();
            while (pointIterator.hasNext()){
                pointIterator.next().draw(gl);
            }
            isBeingDrawn = false;
            Log.d("mCurrentTAG", "drawFinish");



//            if(listPoints == null || listPoints.size() == 0) return;
//                for (Point p : listPoints) {
//                    p.draw(gl);
//                }


        }
    }
}
