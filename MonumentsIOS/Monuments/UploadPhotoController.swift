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

    var locationManager: CLLocationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.previewView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height));
        self.previewView.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(previewView);
        
        //Add a view on top of the cameras' view
        self.boxView = UIView(frame: self.view.frame);
        
        myButton.frame = CGRectMake(0,0,200,40)
        myButton.backgroundColor = UIColor.redColor()
        myButton.layer.masksToBounds = true
        myButton.setTitle("press me", forState: UIControlState.Normal)
        myButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myButton.layer.cornerRadius = 20.0
        myButton.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height - 50)
        myButton.addTarget(self, action: #selector(UploadPhotoController.onClickMyButton(_:)), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(self.boxView);
        self.view.addSubview(myButton)
        
        self.setupAVCapture();
        
        
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(manager: CLLocationManager!,didUpdateLocations locations: [CLLocation])
    {
        var latestLocation: AnyObject = locations[locations.count - 1]
        
       var lat = String(format: "%.4f",
                               latestLocation.coordinate.latitude)
        var long = String(format: "%.4f",
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
        UIGraphicsBeginImageContextWithOptions(self.previewView.bounds.size, true, 0)
        self.previewView.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        arrayImages.append(image!)
    }
}


// AVCaptureVideoDataOutputSampleBufferDelegate protocol and related methods
extension UploadPhotoController:  AVCaptureVideoDataOutputSampleBufferDelegate{
    func setupAVCapture(){
        session.sessionPreset = AVCaptureSessionPreset640x480;
        
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
