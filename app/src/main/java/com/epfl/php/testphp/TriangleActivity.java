package com.epfl.php.testphp;

import android.app.ActivityManager;
import android.content.Context;
import android.content.pm.ConfigurationInfo;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.opengl.GLU;
import android.opengl.Matrix;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.MotionEvent;
import android.view.Window;
import android.view.WindowManager;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

public class TriangleActivity extends AppCompatActivity {

    private LessonSevenGLSurfaceView glView;
    private Triangle		triangle1;
    private Triangle		triangle2;
    private Square square;
    private Point point;
    private MyOpenGLRenderer mRenderer;
    private Point point2;


    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);

            glView = new LessonSevenGLSurfaceView(this);
            final DisplayMetrics displayMetrics = new DisplayMetrics();
            getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);

            mRenderer = new MyOpenGLRenderer(this,glView);
            glView.setRenderer(mRenderer,displayMetrics.density);
            setContentView(glView);




    }



    class MyOpenGLRenderer implements GLSurfaceView.Renderer {




        /**
         * Store the model matrix. This matrix is used to move models from object space (where each model can be thought
         * of being located at the center of the universe) to world space.
         */
        private float[] mModelMatrix = new float[16];

        /**
         * Store the view matrix. This can be thought of as our camera. This matrix transforms world space to eye space;
         * it positions things relative to our eye.
         */
        private float[] mViewMatrix = new float[16];

        /** Store the projection matrix. This is used to project the scene onto a 2D viewport. */
        private float[] mProjectionMatrix = new float[16];

        /** Allocate storage for the final combined matrix. This will be passed into the shader program. */
        private float[] mMVPMatrix = new float[16];

        /** Store the accumulated rotation. */
        private final float[] mAccumulatedRotation = new float[16];

        /** Store the current rotation. */
        private final float[] mCurrentRotation = new float[16];

        /** A temporary matrix. */
        private float[] mTemporaryMatrix = new float[16];

        public float mDeltaX;
        public float mDeltaY;
        private final TriangleActivity triangleActivity;
        private final GLSurfaceView mGlSurfaceView;


        MyOpenGLRenderer(final TriangleActivity triangleActivity, final GLSurfaceView glSurfaceView) {
            this.triangleActivity = triangleActivity;
            mGlSurfaceView = glSurfaceView;
        }

        @Override
        public void onSurfaceChanged(GL10 gl, int width, int height) {
            Log.d("MyOpenGLRenderer", "Surface changed. Width=" + width
                    + " Height=" + height);


//             Set the OpenGL viewport to the same size as the surface.
            GLES20.glViewport(0, 0, width, height);

//             Create a new perspective projection matrix. The height will stay the same
//             while the width will vary as per aspect ratio.
            final float ratio = (float) width / height;
            final float left = -ratio;
            final float right = ratio;
            final float bottom = -1.0f;
            final float top = 1.0f;
            final float near = 1.0f;
            final float far = 100.0f;

//            Matrix.frustumM(mProjectionMatrix, 0, left, right, bottom, top, near, far);


//
//            triangle1 = new Triangle(0.5f, 1, 0, 0);
//            triangle2 = new Triangle(0.5f, 0, 1, 0);
//            gl.glViewport(0, 0, width, height);
//            gl.glMatrixMode(GL10.GL_PROJECTION);
//            gl.glLoadIdentity();
//            GLU.gluPerspective(gl, 45.0f, (float) width / (float) height,
//                    0.1f, 100.0f);
//            gl.glMatrixMode(GL10.GL_MODELVIEW);
//            gl.glLoadIdentity();
//
//            square = new Square();
            point = new Point( -0.50f,  1.0f, 0.0f, 1.0f,0.0f,0.0f);
            point2 = new Point( 0.0f,  0.0f, 0.0f, 0.0f,1.0f,0.0f);


        }



        @Override
        public void onSurfaceCreated(GL10 gl, EGLConfig config) {
            Log.d("MyOpenGLRenderer", "Surface created");
//            mLastRequestedCubeFactor = mActualCubeFactor = 3;
//            generateCubes(mActualCubeFactor, false, false);
//
//            // Set the background clear color to black.
//            GLES20.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
//
//            // Use culling to remove back faces.
//            GLES20.glEnable(GLES20.GL_CULL_FACE);
//
//            // Enable depth testing
//            GLES20.glEnable(GLES20.GL_DEPTH_TEST);
//
//            // Position the eye in front of the origin.
//            final float eyeX = 0.0f;
//            final float eyeY = 0.0f;
//            final float eyeZ = -0.5f;
//
//            // We are looking toward the distance
//            final float lookX = 0.0f;
//            final float lookY = 0.0f;
//            final float lookZ = -5.0f;
//
//            // Set our up vector. This is where our head would be pointing were we holding the camera.
//            final float upX = 0.0f;
//            final float upY = 1.0f;
//            final float upZ = 0.0f;
//
//            // Set the view matrix. This matrix can be said to represent the camera position.
//            // NOTE: In OpenGL 1, a ModelView matrix is used, which is a combination of a model and
//            // view matrix. In OpenGL 2, we can keep track of these matrices separately if we choose.
//            Matrix.setLookAtM(mViewMatrix, 0, eyeX, eyeY, eyeZ, lookX, lookY, lookZ, upX, upY, upZ);
//
//            final String vertexShader = RawResourceReader.readTextFileFromRawResource(mLessonSevenActivity, R.raw.lesson_seven_vertex_shader);
//            final String fragmentShader = RawResourceReader.readTextFileFromRawResource(mLessonSevenActivity, R.raw.lesson_seven_fragment_shader);
//
//            final int vertexShaderHandle = ShaderHelper.compileShader(GLES20.GL_VERTEX_SHADER, vertexShader);
//            final int fragmentShaderHandle = ShaderHelper.compileShader(GLES20.GL_FRAGMENT_SHADER, fragmentShader);
//
//            mProgramHandle = ShaderHelper.createAndLinkProgram(vertexShaderHandle, fragmentShaderHandle,
//                    new String[] {"a_Position",  "a_Normal", "a_TexCoordinate"});
//
//            // Load the texture
//            mAndroidDataHandle = TextureHelper.loadTexture(mLessonSevenActivity, R.drawable.usb_android);
//            GLES20.glGenerateMipmap(GLES20.GL_TEXTURE_2D);
//
//            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mAndroidDataHandle);
//            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
//
//            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mAndroidDataHandle);
//            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR_MIPMAP_LINEAR);
//
//            // Initialize the accumulated rotation matrix
            Matrix.setIdentityM(mAccumulatedRotation, 0);
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



            // Draw a cube.
            point.draw(gl);
            point2.draw(gl);
// Translate the cube into the screen.
            Matrix.setIdentityM(mModelMatrix, 0);
            Matrix.translateM(mModelMatrix, 0, 0.0f, 0.8f, -3.5f);

// Set a matrix that contains the current rotation.
            Matrix.setIdentityM(mCurrentRotation, 0);
            Matrix.rotateM(mCurrentRotation, 0, mDeltaX, 0.0f, 1.0f, 0.0f);
            Matrix.rotateM(mCurrentRotation, 0, mDeltaY, 1.0f, 0.0f, 0.0f);
            mDeltaX = 0.0f;
            mDeltaY = 0.0f;

// Multiply the current rotation by the accumulated rotation, and then set the accumulated
// rotation to the result.
            Matrix.multiplyMM(mTemporaryMatrix, 0, mCurrentRotation, 0, mAccumulatedRotation, 0);
            System.arraycopy(mTemporaryMatrix, 0, mAccumulatedRotation, 0, 16);

// Rotate the cube taking the overall rotation into account.
            Matrix.multiplyMM(mTemporaryMatrix, 0, mModelMatrix, 0, mAccumulatedRotation, 0);
            System.arraycopy(mTemporaryMatrix, 0, mModelMatrix, 0, 16);
            gl.glMultMatrixf(mAccumulatedRotation, 0);

//            // Clears the screen and depth buffer.
//            gl.glClear(GL10.GL_COLOR_BUFFER_BIT |
//                    GL10.GL_DEPTH_BUFFER_BIT);

            // Draw our square.
//            gl.glLoadIdentity();
//            gl.glTranslatef(0, 0, -5);

//            square.draw(gl); // ( NEW )
//            point.draw(gl);
//            point2.draw(gl);
        }
    }
}
