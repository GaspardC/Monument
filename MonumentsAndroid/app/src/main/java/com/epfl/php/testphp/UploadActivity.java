package com.epfl.php.testphp;

import android.Manifest;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.hardware.Camera;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;

import android.os.CountDownTimer;
import android.os.Environment;
import android.provider.Settings;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextSwitcher;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ViewSwitcher;


import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Timer;

import it.moondroid.coverflow.components.ui.containers.FeatureCoverFlow;

public class UploadActivity extends AppCompatActivity implements SensorEventListener {


    private static final int MY_PERMISSIONS_REQUEST_FINE_LOCATION = 0;
    private static final int MY_PERMISSIONS_REQUEST_COARSE_LOCATION = 1;
    TextView content, geoDataTextView;
    private static String SERVER_ADRESS = "http://dhlabsrv4.epfl.ch/wtm/add.php";
    private String SERVER_URL = "http://udle-blog.com/db16/gaspard/add.php";
    private static final String TAG = UploadActivity.class.getSimpleName();



    private Bitmap bitmapImage;
    private ProgressDialog dialog;
    private String selectedFilePath;
    private StringBuffer response;
    private JSONObject geo_data;

    LocationManager locationManager;
    double longitudeBest, latitudeBest;


    private ArrayList<PhotoEntity> mData = new ArrayList<>(0);
    private TextSwitcher mTitle;
    private ListCurrentPhotos listCurrentPhotos;

    private Camera mCamera;
    private CameraPreview mCameraPreview;

    private SensorManager mSensorManager;
    private Sensor mAccelerometer;
    private double azimuth;
    float[] mGravity = new float[50];
    float[] mGeomagnetic = new float[50];

    SensorManager sensorManager;
    private Sensor sensorAccelerometer;
    private Sensor sensorMagneticField;

    private float[] valuesAccelerometer;
    private float[] valuesMagneticField;

    private float[] matrixR;
    private float[] matrixI;
    private float[] matrixValues;

    Timer timer = new Timer();
    private FrameLayout preview;
    Camera.PictureCallback mPicture;
    private PhotoEntity lastPhotoEntity;
    private boolean cameraIsRecording = false;


    @Override

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_upload);

        listCurrentPhotos = new ListCurrentPhotos(this);

        content = (TextView) findViewById(R.id.content);
        geoDataTextView = (TextView) findViewById(R.id.geo_data);

        geo_data = new JSONObject();

        getLoc();
//        sensorActivity = new SensorActivity();
        sensorManager = (SensorManager)getSystemService(SENSOR_SERVICE);
        sensorAccelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        sensorMagneticField = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD);

        valuesAccelerometer = new float[3];
        valuesMagneticField = new float[3];
        matrixR = new float[9];
        matrixI = new float[9];
        matrixValues = new float[3];
        mSensorManager = (SensorManager)getSystemService(SENSOR_SERVICE);
        mAccelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        updateAzimuth();
        setUploadBehavior();

        listCurrentPhotos.setDefautlPhotos();
        mData = listCurrentPhotos.listPhoto;
        setTitle();
        resetPhotos(null);
        setUpCoverFlow();
        preview = (FrameLayout) findViewById(R.id.camera_preview);
        setUpCamera();



    }

    private void updateAzimuth() {
        try {
            geo_data.put("azimuth",azimuth);
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    private void setUpCamera() {
        mPicture = new Camera.PictureCallback() {
            @Override
            public void onPictureTaken(byte[] data, Camera camera) {
                File pictureFile = getOutputMediaFile();
                if (pictureFile == null) {
                    mCamera.stopPreview();
                    mCamera.startPreview();
                    mCameraPreview.safeToTakePicture = true;

                    return;
                }
                try {
                    FileOutputStream fos = new FileOutputStream(pictureFile);
                    fos.write(data);
                    fos.close();
                    Bitmap bitmap = PhotoManager.resizeIfNeeded(400,pictureFile.getAbsolutePath());
                    ArrayList<PhotoEntity> listPhotos = listCurrentPhotos.listPhoto;
                    if(listPhotos.size() == 1 && listPhotos.get(0).filename.equals("no images")){
                        listPhotos.remove(0);
                    }
                    updateAzimuth();
                    lastPhotoEntity = new PhotoEntity(bitmap,pictureFile.getAbsolutePath(),updateLocationJson(null));
                    new Thread(new Runnable() {
                        @Override
                        public void run() {

                            try {
                                //creating new thread to handle Http Operations
                                    uploadFile(lastPhotoEntity);

                            } catch (OutOfMemoryError e) {

                                runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        Toast.makeText(UploadActivity.this, "Insufficient Memory!", Toast.LENGTH_SHORT).show();
                                    }
                                });

                            }

                        }
                    }).start();
                    listPhotos.add(lastPhotoEntity);
                    setUpCoverFlow();

                } catch (FileNotFoundException e) {
                    Log.d("exeception",e.toString());

                } catch (IOException e) {
                    Log.d("exeception",e.toString());
                }
                mCamera.stopPreview();
                mCamera.startPreview();
                mCameraPreview.safeToTakePicture = true;

            }

        };


        mCamera = getCameraInstance();
        mCameraPreview = new CameraPreview(this, mCamera);
        preview.addView(mCameraPreview);
        mCamera.startPreview();


        final Button captureButton = (Button) findViewById(R.id.button_capture);
        assert captureButton != null;
        captureButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if(!cameraIsRecording){
                    cameraIsRecording = true;
                    captureButton.setBackground(getDrawable(R.drawable.button_cam_recording));
                    new CountDownTimer(20000,2000){

                        @Override
                        public void onFinish() {
                            captureButton.setBackground(getDrawable(R.drawable.button_cam));

                        }

                        @Override
                        public void onTick(long millisUntilFinished) {
                            if (mCameraPreview.safeToTakePicture) {
                                mCamera.takePicture(null, null, mPicture);
                                mCameraPreview.safeToTakePicture = false;
                            }
                        }

                    }.start();
                }
                else{
                    timer.cancel();
                    cameraIsRecording = false;
                    captureButton.setBackground(getDrawable(R.drawable.button_cam));

                }

                }


        });
    }

    /**
     * Helper method to access the camera returns null if it cannot get the
     * camera or does not exist
     *
     * @return
     */
    private Camera getCameraInstance() {
        Camera camera = null;
        try {
            camera = Camera.open();
        } catch (Exception e) {
            // cannot get camera or does not exist
            e.printStackTrace();

        }
        return camera;
    }



    private static File getOutputMediaFile() {
        File mediaStorageDir = new File(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES),
                "MyCameraApp");
        if (!mediaStorageDir.exists()) {
            if (!mediaStorageDir.mkdirs()) {
                Log.d("MyCameraApp", "failed to create directory");
                return null;
            }
        }
        // Create a media file name
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss")
                .format(new Date());
        File mediaFile;
        mediaFile = new File(mediaStorageDir.getPath() + File.separator
                + "IMG_" + timeStamp + ".jpg");

        return mediaFile;
    }

    private void setTitle() {
        mTitle = (TextSwitcher) findViewById(R.id.title);
        mTitle.setFactory(new ViewSwitcher.ViewFactory() {
            @Override
            public View makeView() {
                LayoutInflater inflater = LayoutInflater.from(UploadActivity.this);
                TextView textView = (TextView) inflater.inflate(R.layout.item_title, null);
                return textView;
            }
        });
        Animation in = AnimationUtils.loadAnimation(this, R.anim.slide_in_top);
        Animation out = AnimationUtils.loadAnimation(this, R.anim.slide_out_bottom);
        mTitle.setInAnimation(in);
        mTitle.setOutAnimation(out);
    }

    private void setUpCoverFlow() {


        CoverFlowAdapter mAdapter = new CoverFlowAdapter(this);
        mAdapter.setData(mData);
        FeatureCoverFlow mCoverFlow = (FeatureCoverFlow) findViewById(R.id.coverflow);
        mCoverFlow.setVisibility(View.VISIBLE);
        mCoverFlow.setAdapter(mAdapter);

        mCoverFlow.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                position = position % mData.size();
                Toast.makeText(UploadActivity.this, mData.get(position).filename,
                        Toast.LENGTH_SHORT).show();
            }
        });

        mCoverFlow.setOnScrollPositionListener(new FeatureCoverFlow.OnScrollPositionListener() {
            @Override
            public void onScrolledToPosition(int position) {
                mTitle.setText(mData.get(position).filename);
            }

            @Override
            public void onScrolling() {
                mTitle.setText("");
            }
        });

    }

    private void setUploadBehavior() {

        Button saveme = (Button) findViewById(R.id.save);

        assert saveme != null;
        saveme.setOnClickListener(new Button.OnClickListener() {

            public void onClick(View v) {
                try {

                    if (listCurrentPhotos.listPhoto.size() == 0) return;

                    dialog = ProgressDialog.show(UploadActivity.this, "", "Uploading File...", true);

                    new Thread(new Runnable() {
                        @Override
                        public void run() {

                            try {
                                //creating new thread to handle Http Operations
                                for(PhotoEntity pE : listCurrentPhotos.listPhoto){
                                    uploadFile(pE);
                                }
                            } catch (OutOfMemoryError e) {

                                runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        Toast.makeText(UploadActivity.this, "Insufficient Memory!", Toast.LENGTH_SHORT).show();
                                    }
                                });
                                dialog.dismiss();
                            }

                        }
                    }).start();

                    // CALL GetText method to make post method call
                } catch (Exception ex) {
                    content.setText(" url exeption! " + ex.toString());
                }
            }
        });
    }

    private void getLoc() {

        locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        if(!isLocationEnabled()){
            showAlert();
        }
        Criteria criteria = new Criteria();
        criteria.setAccuracy(Criteria.ACCURACY_FINE);
        criteria.setAltitudeRequired(false);
        criteria.setBearingRequired(false);
        criteria.setCostAllowed(true);
        criteria.setPowerRequirement(Criteria.POWER_LOW);
        String provider = locationManager.getBestProvider(criteria, true);
        if (provider != null) {
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                // TODO: Consider calling
                //    ActivityCompat#requestPermissions
                // here to request the missing permissions, and then overriding
                //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
                //                                          int[] grantResults)
                // to handle the case where the user grants the permission. See the documentation
                // for ActivityCompat#requestPermissions for more details.
                ActivityCompat.requestPermissions(UploadActivity.this,
                        new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                        MY_PERMISSIONS_REQUEST_FINE_LOCATION);
                ActivityCompat.requestPermissions(UploadActivity.this,
                        new String[]{Manifest.permission.ACCESS_COARSE_LOCATION},
                        MY_PERMISSIONS_REQUEST_COARSE_LOCATION);
            }
            locationManager.requestLocationUpdates(provider, 1 * 5 * 1000, 10, locationListenerBest);
            Location lastLoc = locationManager.getLastKnownLocation(provider);
             updateLocationJson(lastLoc);

           // Toast.makeText(this, "Best Provider is " + provider, Toast.LENGTH_LONG).show();

        }
    }
    private boolean isLocationEnabled() {
        return locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
                locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
    }
    private void showAlert() {
        final AlertDialog.Builder dialog = new AlertDialog.Builder(this);
        dialog.setTitle("Enable Location")
                .setMessage("Your Locations Settings is set to 'Off'.\nPlease Enable Location to " +
                        "use this app")
                .setPositiveButton("Location Settings", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface paramDialogInterface, int paramInt) {
                        Intent myIntent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
                        startActivity(myIntent);
                    }
                })
                .setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface paramDialogInterface, int paramInt) {
                    }
                });
        dialog.show();
    }


    public int uploadFile( PhotoEntity photoEntity) {

        selectedFilePath = photoEntity.filename;
        int serverResponseCode = 0;

        HttpURLConnection connection;
        DataOutputStream dataOutputStream;
        String lineEnd = "\r\n";
        String twoHyphens = "--";
        String boundary = "*****";


        int bytesRead, bytesAvailable, bufferSize;
        byte[] buffer;
        int maxBufferSize = 1 * 1024 * 1024;
        File selectedFile = new File(selectedFilePath);


        String[] parts = selectedFilePath.split("/");
        final String fileName = parts[parts.length - 1];

        if (!selectedFile.isFile()) {
            dialog.dismiss();

            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    content.setText("Source File Doesn't Exist: " + selectedFilePath);
                }
            });
            return 0;
        } else {
            try {
                FileInputStream fileInputStream = new FileInputStream(selectedFile);
                URL url = new URL(SERVER_ADRESS);
                connection = (HttpURLConnection) url.openConnection();
                connection.setDoInput(true);//Allow Inputs
                connection.setDoOutput(true);//Allow Outputs
                connection.setUseCaches(false);//Don't use a cached Copy
                connection.setRequestMethod("POST");
                connection.setRequestProperty("Connection", "Keep-Alive");
                connection.setRequestProperty("ENCTYPE", "multipart/form-data");
                connection.setRequestProperty(
                        "Content-Type", "multipart/form-data;boundary=" + boundary);
                connection.setRequestProperty("picture",selectedFilePath);


                //creating new dataoutputstream
                dataOutputStream = new DataOutputStream(connection.getOutputStream());

                //writing bytes to data outputstream

                dataOutputStream.writeBytes(twoHyphens + boundary + lineEnd);
                dataOutputStream.writeBytes("Content-Disposition: form-data; name=\"user_id\""+ lineEnd);
                dataOutputStream.writeBytes(lineEnd);
                dataOutputStream.writeBytes(MonumentApplication.user_id);
                dataOutputStream.writeBytes(lineEnd);


                dataOutputStream.writeBytes(twoHyphens + boundary + lineEnd);
                dataOutputStream.writeBytes("Content-Disposition: form-data; name=\"geo_data\""+ lineEnd);
                dataOutputStream.writeBytes(lineEnd);
                dataOutputStream.writeBytes(photoEntity.jLoc.toString());
                dataOutputStream.writeBytes(lineEnd);


                dataOutputStream.writeBytes(twoHyphens + boundary + lineEnd);
                dataOutputStream.writeBytes("Content-Disposition: form-data; name=\"picture\";filename=\""
                        + selectedFilePath + "\"" + lineEnd);

                dataOutputStream.writeBytes(lineEnd);


                //returns no. of bytes present in fileInputStream
                bytesAvailable = fileInputStream.available();
                //selecting the buffer size as minimum of available bytes or 1 MB
                bufferSize = Math.min(bytesAvailable, maxBufferSize);
                //setting the buffer as byte array of size of bufferSize
                buffer = new byte[bufferSize];

                //reads bytes from FileInputStream(from 0th index of buffer to buffersize)
                bytesRead = fileInputStream.read(buffer, 0, bufferSize);


                //loop repeats till bytesRead = -1, i.e., no bytes are left to read
                while (bytesRead > 0) {

                    try {

                        //write the bytes read from inputstream
                        dataOutputStream.write(buffer, 0, bufferSize);
                    } catch (OutOfMemoryError e) {
                        Toast.makeText(UploadActivity.this, "Insufficient Memory!", Toast.LENGTH_SHORT).show();
                    }
                    bytesAvailable = fileInputStream.available();
                    bufferSize = Math.min(bytesAvailable, maxBufferSize);
                    bytesRead = fileInputStream.read(buffer, 0, bufferSize);
                }

                dataOutputStream.writeBytes(lineEnd);
                dataOutputStream.writeBytes(twoHyphens + boundary + twoHyphens + lineEnd);

                try{
                    serverResponseCode = connection.getResponseCode();
                }catch (OutOfMemoryError e){
                    Toast.makeText(UploadActivity.this, "Memory Insufficient!", Toast.LENGTH_SHORT).show();
                }
                String serverResponseMessage = connection.getResponseMessage();

                Log.i(TAG, "Server Response is: " + serverResponseMessage + ": " + serverResponseCode);

                //response code of 200 indicates the server status OK
                if (serverResponseCode == 200) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            //Toast done
                        }
                    });
                }
                //Get Response
                InputStream is = connection.getInputStream();
                BufferedReader rd = new BufferedReader(new InputStreamReader(is));
                String line;
                response = new StringBuffer();
                while ((line = rd.readLine()) != null) {
                    response.append(line);
                    response.append('\r');
                }
                rd.close();
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        content.setText(response.toString());

                    }
                });

                //closing the input and output streams
                fileInputStream.close();
                dataOutputStream.flush();
                dataOutputStream.close();

//                if (wakeLock.isHeld()) {
//
//                    wakeLock.release();
//                }


            } catch (FileNotFoundException e) {
                e.printStackTrace();
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(UploadActivity.this, "File Not Found", Toast.LENGTH_SHORT).show();
                    }
                });
            } catch (MalformedURLException e) {
                e.printStackTrace();
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(UploadActivity.this, "URL Error!", Toast.LENGTH_SHORT).show();
                    }
                });

            } catch (IOException e) {
                e.printStackTrace();
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(UploadActivity.this, "Cannot Read/Write File", Toast.LENGTH_SHORT).show();
                    }
                });
            }
            if(dialog!= null ) dialog.dismiss();
            return serverResponseCode;
        }

    }


    public void takePhotos(View view) {
        PhotoManager.takePhoto(UploadActivity.this);
    }



    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        try {
            // When an Image is picked from Library
            if (requestCode == MonumentApplication.RESULT_LOAD_IMG && resultCode == RESULT_OK
                    && null != data) {
                Bitmap libraryBitmap = PhotoManager.getBitmapFromLibrary(this, requestCode, resultCode, data);
                if (libraryBitmap != null) {
                    ImageView img = (ImageView) findViewById(R.id.imageRes);
                    img.setImageBitmap(libraryBitmap);
                    bitmapImage = libraryBitmap;

                }
            }

            // When an Image is taken by Camera
            if (requestCode == MonumentApplication.TAKE_PHOTO_CODE && resultCode == RESULT_OK) {

                Bitmap cameraBitmap = PhotoManager.getBitmapFromCamera(this, requestCode, resultCode);
                if (cameraBitmap != null) {
                    ImageView img = (ImageView) findViewById(R.id.imageRes);
                    img.setImageBitmap(cameraBitmap);
                    bitmapImage = cameraBitmap;
                }
            }
            selectedFilePath = MonumentApplication.fileName;


        } catch (Exception e) {
            Toast.makeText(this, "Something went wrong", Toast.LENGTH_LONG).show();
        }

    }

    private final LocationListener locationListenerBest = new LocationListener() {
        public void onLocationChanged(Location location) {


            updateLocationJson(location);

        }

        @Override
        public void onStatusChanged(String s, int i, Bundle bundle) {

        }

        @Override
        public void onProviderEnabled(String s) {

        }

        @Override
        public void onProviderDisabled(String s) {

        }
    };

    private JSONObject updateLocationJson(Location location) {

        JSONObject jLocation = new JSONObject();

        if(location == null) {
            try {

                jLocation.put("lat", latitudeBest);
                jLocation.put("long", longitudeBest);
                geo_data.put("location", jLocation);

                geoDataTextView.setText(geo_data.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        else {


            longitudeBest = location.getLongitude();
            latitudeBest = location.getLatitude();


            try {
                jLocation.put("lat", latitudeBest);
                jLocation.put("long", longitudeBest);
                geo_data.put("location", jLocation);
                geoDataTextView.setText(geo_data.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }



        Log.d("best loc", "long : "+ longitudeBest + " latt : " + latitudeBest);

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Log.d("provider","Best Provider update");
//                Toast.makeText(UploadActivity.this, "Best Provider update", Toast.LENGTH_SHORT).show();
            }
        });

        return jLocation;

    }


    public void resetPhotos(View view) {
        listCurrentPhotos.resetListPhoto();
        mData = listCurrentPhotos.listPhoto;
        setUpCoverFlow();
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {
    }
    @Override
    public void onSensorChanged(SensorEvent event) {

        switch(event.sensor.getType()){
            case Sensor.TYPE_ACCELEROMETER:
                for(int i =0; i < 3; i++){
                    valuesAccelerometer[i] = event.values[i];
                }
                break;
            case Sensor.TYPE_MAGNETIC_FIELD:
                for(int i =0; i < 3; i++){
                    valuesMagneticField[i] = event.values[i];
                }
                break;
        }

        boolean success = SensorManager.getRotationMatrix(
                matrixR,
                matrixI,
                valuesAccelerometer,
                valuesMagneticField);

        if(success) {
            SensorManager.getOrientation(matrixR, matrixValues);

            azimuth = Math.toDegrees(matrixValues[0]);
            double pitch = Math.toDegrees(matrixValues[1]);
            double roll = Math.toDegrees(matrixValues[2]);
            //Log.d("azimuth",String.valueOf(azimuth));

        }


    }

    @Override
    protected void onResume() {
        super.onResume();
//        mSensorManager.registerListener(this, mAccelerometer, SensorManager.SENSOR_DELAY_NORMAL);
        sensorManager.registerListener(this,
                sensorAccelerometer,
                SensorManager.SENSOR_DELAY_NORMAL);
        sensorManager.registerListener(this,
                sensorMagneticField,
                SensorManager.SENSOR_DELAY_NORMAL);

        // Get the Camera instance as the activity achieves full user focus
        if (mCamera == null) {
            setUpCamera(); // Local method to handle camera initialization
        }

    }

    @Override
    protected void onPause() {
        super.onPause();
        mSensorManager.unregisterListener(this);
        if (mCamera != null) {
            mCamera.setPreviewCallback(null);
            mCameraPreview.getHolder().removeCallback(mCameraPreview);
            mCamera.stopPreview();
            mCamera.release();
            mCamera = null;
            preview.removeView(mCameraPreview);
            mCameraPreview = null;
        }

    }





}
