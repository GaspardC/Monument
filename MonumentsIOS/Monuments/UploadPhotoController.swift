//
//  UploadPhotoController.swift
//  Monuments
//
//  Created by Gaspard Chevassus on 02/07/2016.
//  Copyright © 2016 Gaspard Chevassus. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import CoreMotion



class UploadPhotoController: UIViewController , CLLocationManagerDelegate{
    var previewView : UIView!;
    var boxView:UIView!;
    let myButton: UIButton = UIButton()
    
    //Camera Capture requiered properties
    var videoDataOutput: AVCaptureVideoDataOutput!;
    var videoDataOutputQueue : dispatch_queue_t!;
    var previewLayer:AVCaptureVideoPreviewLayer!;
    var captureDevice : AVCaptureDevice!
    let session=AVCaptureSession();
    var arrayImages = Array<UIImage>()
    var uniqueIdentifier:String!
    let jSonValues:NSMutableDictionary = NSMutableDictionary()
    var stillImageOutput: AVCaptureStillImageOutput!

    var locationManager: CLLocationManager = CLLocationManager()
    var lat:String = ""
    var long:String = ""
    var azimuth: String = "default_id"
    
    
    
    let motionManager: CMMotionManager = CMMotionManager()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.previewView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height));
        self.previewView.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(previewView);
        
        //Add a view on top of the cameras' view
        self.boxView = UIView(frame: self.view.frame);
        
        myButton.frame = CGRectMake(0,0,60,60)
        myButton.backgroundColor = UIColor.redColor()
        myButton.layer.masksToBounds = true
//        myButton.setTitle("press me", forState: UIControlState.Normal)
        myButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myButton.layer.cornerRadius = 30.0
        myButton.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height - 45)
        myButton.addTarget(self, action: #selector(UploadPhotoController.onClickMyButton(_:)), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(self.boxView);
        self.view.addSubview(myButton)
        
        self.setupAVCapture();
        
        
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
        motionManager.deviceMotionUpdateInterval = 0.2
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler:{
            deviceManager, error in
            print("Test") // no print
        })
        
        print(motionManager.deviceMotionActive)
        
        if motionManager.accelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.01
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMAccelerometerData?, error: NSError?) in
                if let acceleration = data?.acceleration {
//                    print(acceleration.y)
                    self!.azimuth = String(format: "%f",acceleration.y)
                }
            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(manager: CLLocationManager!,didUpdateLocations locations: [CLLocation])
    {
        var latestLocation: AnyObject = locations[locations.count - 1]
        
         lat = String(format: "%.4f",
                               latestLocation.coordinate.latitude)
         long = String(format: "%.4f",
                                latestLocation.coordinate.longitude)
        }
    
    func locationManager(manager: CLLocationManager!,
                         didFailWithError error: NSError!) {
        
    }
    
    
    override func shouldAutorotate() -> Bool {
        if (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.Unknown) {
            return false;
        }
        else {
            return true;
        }
    }
    
    func onClickMyButton(sender: UIButton){
        print("button pressed")
        
        
        let v = UIView(frame: self.view.bounds)
        v.backgroundColor = UIColor.whiteColor()
        v.alpha = 1
        
        self.view.addSubview(v)
        UIView.animateWithDuration(0.6, animations: {
            v.alpha = 0.0
            }, completion: {(finished:Bool) in
                print("flash")
                v.removeFromSuperview()
        })
        
        
        
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)) { (buffer:CMSampleBuffer!, error:NSError!) -> Void in
            let image = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            let data_image = UIImage(data: image)
            self.arrayImages.append(data_image!)

        }
    }
    
   }


// AVCaptureVideoDataOutputSampleBufferDelegate protocol and related methods
extension UploadPhotoController:  AVCaptureVideoDataOutputSampleBufferDelegate{
    func setupAVCapture(){
        session.sessionPreset = AVCaptureSessionPresetHigh;
        
        let devices = AVCaptureDevice.devices();
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the front camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice;
                    if captureDevice != nil {
                        beginSession();
                        break;
                    }
                }
            }
        }
    }
    
    func beginSession(){
        var err : NSError? = nil
        var deviceInput:AVCaptureDeviceInput?
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error as NSError {
            err = error
            deviceInput = nil
        };
        if err != nil {
            print("error: \(err?.localizedDescription)");
        }
        if self.session.canAddInput(deviceInput){
            self.session.addInput(deviceInput);
        }
        
        self.stillImageOutput = AVCaptureStillImageOutput()
        self.session.addOutput(self.stillImageOutput)
        
//        do {
//            try self.session.addInput(AVCaptureDeviceInput(device: captureDevice))
//        } catch let error as NSError {
//            print(error)
//        }
        
        
        self.videoDataOutput = AVCaptureVideoDataOutput();
        self.videoDataOutput.alwaysDiscardsLateVideoFrames=true;
        self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        self.videoDataOutput.setSampleBufferDelegate(self, queue:self.videoDataOutputQueue);
        if session.canAddOutput(self.videoDataOutput){
            session.addOutput(self.videoDataOutput);
        }
        self.videoDataOutput.connectionWithMediaType(AVMediaTypeVideo).enabled = true;
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session);
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        
        let rootLayer :CALayer = self.previewView.layer;
        rootLayer.masksToBounds=true;
        self.previewLayer.frame = rootLayer.bounds;
        rootLayer.addSublayer(self.previewLayer);
        session.startRunning();
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        // do stuff here
    }
    
    // clean up AVCapture
    func stopCamera(){
        session.stopRunning()
    }
    
}
