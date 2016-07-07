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
    let buttonTakePicture: UIButton = UIButton()
    let buttonCountDown: UIButton = UIButton()
    var INITIAL_COUNT_DOWN_VALUE = 10
    //Camera Capture requiered properties
    var videoDataOutput: AVCaptureVideoDataOutput!;
    var videoDataOutputQueue : dispatch_queue_t!;
    var previewLayer:AVCaptureVideoPreviewLayer!;
    var captureDevice : AVCaptureDevice!
    let session=AVCaptureSession();
    var arrayImages = Array<PhotoEntity>()
    var uniqueIdentifier:String!
    let jSonValues:NSMutableDictionary = NSMutableDictionary()
    var stillImageOutput: AVCaptureStillImageOutput!

    var locationManager: CLLocationManager = CLLocationManager()
    var lat:String = ""
    var long:String = ""
    var azimuth: String = ""
    var countDown = 30
    
    var photoEntity = PhotoEntity();
    
    
    let motionManager: CMMotionManager = CMMotionManager()

    let url_to_request:String = "http://udle-blog.com/db16/gaspard/add.php"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (uniqueIdentifier == ""){
            uniqueIdentifier = "user_ios_test_id"
        }
        self.previewView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height));
        self.previewView.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(previewView);
        

        self.setupAVCapture();
        
        countDown = INITIAL_COUNT_DOWN_VALUE
        setUpButtons()
        
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
    
    func setUpButtons() -> () {
        
        //Add a counter down view on top of the cameras' view
        //        self.boxView = UIView(frame: self.view.frame);
        
        
        buttonCountDown.frame = CGRectMake(0,0,40,40)
        buttonCountDown.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.0)
        buttonCountDown.layer.masksToBounds = true
        buttonCountDown.layer.borderWidth = 3
        buttonCountDown.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.7).CGColor//
        buttonCountDown.setTitle(String(countDown), forState: UIControlState.Normal)
        buttonCountDown.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonCountDown.layer.cornerRadius = 3.0
        buttonCountDown.layer.position = CGPoint(x: self.view.frame.width - 35, y: 50)
        buttonCountDown.addTarget(self, action: #selector(UploadPhotoController.onClickbuttonCountDown(_:)), forControlEvents: .TouchUpInside)
        
        
        buttonTakePicture.frame = CGRectMake(0,0,80,80)
        buttonTakePicture.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        buttonTakePicture.layer.masksToBounds = true
        buttonTakePicture.layer.borderWidth = 4
        buttonTakePicture.layer.borderColor = UIColor.whiteColor().CGColor//
        
        //        buttonTakePicture.setTitle("press me", forState: UIControlState.Normal)
        buttonTakePicture.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonTakePicture.layer.cornerRadius = 40.0
        buttonTakePicture.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height - 60)
        buttonTakePicture.addTarget(self, action: #selector(UploadPhotoController.onClickbuttonTakePicture(_:)), forControlEvents: .TouchUpInside)
        
        //        self.view.addSubview(self.boxView);
        self.view.addSubview(buttonTakePicture)
        self.view.addSubview(buttonCountDown)
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(manager: CLLocationManager,didUpdateLocations locations: [CLLocation])
    {
        let latestLocation: AnyObject = locations[locations.count - 1]
        
         lat = String(format: "%.4f",
                               latestLocation.coordinate.latitude)
         long = String(format: "%.4f",
                                latestLocation.coordinate.longitude)
        }
    
    func locationManager(manager: CLLocationManager,
                         didFailWithError error: NSError) {
        
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
    
    func onClickbuttonCountDown(sender: UIButton){
        print("countdown clicked")
        if (INITIAL_COUNT_DOWN_VALUE == 0){
            INITIAL_COUNT_DOWN_VALUE = 30
        }
        else{
            INITIAL_COUNT_DOWN_VALUE -= 2
        }
        countDown = INITIAL_COUNT_DOWN_VALUE
        buttonCountDown.setTitle(String(INITIAL_COUNT_DOWN_VALUE), forState: UIControlState.Normal)

        
    }
    
    func uploadPhoto(pE : PhotoEntity ) -> () {
        
        
        let request = NSMutableURLRequest(URL: NSURL(string:url_to_request)!)
        request.HTTPMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        //define the multipart request type
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let image : UIImage = pE.image
        
        let image_data = UIImageJPEGRepresentation(image, 100.0)
        
        
        if(image_data == nil)
        {
            return
        }
        
        
        let body = NSMutableData()
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .MediumStyle
        
        let dateString = formatter.stringFromDate( NSDate())
        
        let fname = dateString
        let mimetype = "image/jpeg"
        
        //define the data post parameter
        
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition:form-data; name=\"user_id\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(uniqueIdentifier.dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition:form-data; name=\"geo_data\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData((pE.jsonString).dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)

        
        
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition:form-data; name=\"picture\"; filename=\"\(fname)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Type: \(mimetype)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(image_data!)
        body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        body.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        
        request.HTTPBody = body
        
        
        
        let session = NSURLSession.sharedSession()
        
        
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(dataString)
            
        }
        
        task.resume()
        
        
        
        
//        let data = (("user_id="+uniqueIdentifier)+"&"+("geo_data="+String(pE.json))+"&"+).dataUsingEncoding(NSUTF8StringEncoding)
        
       
        
    }
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    func onClickbuttonTakePicture(sender: UIButton){
        print("button pressed")
        
        
        // Create Flash Animation
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
        
        
        
        // Take the pho directly from the camera (not the preview)
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)) { (buffer:CMSampleBuffer!, error:NSError!) -> Void in
            let image = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            let data_image = UIImage(data: image)
            //self.arrayImages.append(data_image!)

            
            // Save the photoEntity
            self.photoEntity = PhotoEntity(image: data_image!,JSONData: NSData(),azimuth: self.azimuth,long: self.long,lat: self.lat)
            self.uploadPhoto(self.photoEntity)
            self.arrayImages.append(self.photoEntity)
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
