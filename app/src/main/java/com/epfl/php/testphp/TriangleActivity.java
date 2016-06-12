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

import java.util.ArrayList;

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
        glView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
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
        ArrayList<Point> listPoint = new ArrayList<>();
        for (int i = 0; i<300;i++){
            float x = (float) (2.0f * Math.random() -1.0f) ;
            float y = (float) (2.0f * Math.random() -1.0f) ;
            float z = (float) (2.0f * Math.random() -1.0f) ;

            float red = (float) Math.random();
            float green = (float) Math.random();
            float blue = (float) Math.random();
            float alpha = (float) Math.random();
            listPoint.add(new Point(x,y,z,red,green,blue,alpha));

        }
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
                return true;
            }
        });

    }
    static class MyPinchListener extends ScaleGestureDetector.SimpleOnScaleGestureListener {

        private TriangleActivity activity;

        public MyPinchListener(TriangleActivity triangleActivity) {
            activity = triangleActivity;
        }

        @Override
        public boolean onScale(ScaleGestureDetector detector) {
            Log.d("TAG", "PINCH! OUCH!" + String.valueOf(detector.getScaleFactor()));
            activity.scale *=  detector.getScaleFactor();
            return true;
        }
    }


    private class MyOpenGLRenderer implements GLSurfaceView.Renderer {

        public float mDeltaX;
        public float mDeltaY;
        private ArrayList<Point> listPoints;

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
            for(Point p : listPoints){
                p.draw(gl);
            }
        }
    }
}
