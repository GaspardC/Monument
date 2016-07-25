//
//  DisplayPOintsViewController.swift
//  Monuments
//
//  Created by Gaspard Chevassus on 10/07/2016.
//  Copyright © 2016 Gaspard Chevassus. All rights reserved.
//


import UIKit
import GLKit
import Foundation

class GLKUpdater : NSObject, GLKViewControllerDelegate {
    
    weak var glkViewController : GLKViewController!
    
    //"http://dhlabsrv4.epfl.ch/wtm/get.php?f=venezia-gesuati&s=6136209"
    
    init(glkViewController : GLKViewController) {
        self.glkViewController = glkViewController
    }
    
    
    func glkViewControllerUpdate(controller: GLKViewController) {
        
    }
}


class DisplayPOintsViewController: GLKViewController {
    
    var glkView: GLKView!
    var glkUpdater: GLKUpdater!
    
    var _increasing: Bool!
    var _curRed: Float = 0.0
    var roation:Float = 0.0
    var rotMatrix: GLKMatrix4! = GLKMatrix4()
    var anchor_position: GLKVector3! = GLKVector3()
    var current_position:GLKVector3! = GLKVector3()
    var quatStart:GLKQuaternion! = GLKQuaternion()
    var quat:GLKQuaternion! = GLKQuaternion()
    var slerping:Bool = true
    var slerpCur:Float = 0.0
    var slerpMax:Float = 1.0
    

    var shader : BaseEffect!
    var square : Square!

    var loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    
    var slerpStart:GLKQuaternion! = GLKQuaternion()
    var slerpEnd: GLKQuaternion! = GLKQuaternion()
//    var effect:GLKBaseEffect!
    
    
    var vertexBuffer : GLuint = 0
    var indexBuffer: GLuint = 0
    
    var vertices : [Vertex] = [
        Vertex( -0.8, 0.8, 0, 1.0, 1.0, 1.0, 0.0)

    ]
    
    
    @IBAction func startSpinning() {
        loadingIndicator.startAnimating()
        loadingIndicator.hidden = false
    }
    
    @IBAction func stopSpinning() {
       
        loadingIndicator.stopAnimating()
        loadingIndicator.hidden = true

    }
    
    
    
    
    func update() {
        
//        let aspect: Float = fabsf(Float(self.view.bounds.size.width / self.view.bounds.size.height))
//        let projectionMatrix: GLKMatrix4 = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(0), aspect, 1.0, 150.0)
//        
//        
////        self.effect.transform.projectionMatrix = projectionMatrix
//          self.shader.projectionMatrix = projectionMatrix
////          self.shader.projectionMatrix =  GLKMatrix4Identity
//
//
////        if slerping {
////            self.slerpCur += Float(self.timeSinceLastUpdate)
////            var slerpAmt: Float = slerpCur / slerpMax
////            if slerpAmt > 1.0 {
////                slerpAmt = 1.0
////                self.slerping = false
////            }
////            self.quat = GLKQuaternionSlerp(slerpStart, slerpEnd, slerpAmt)
////        }
//        var modelViewMatrix: GLKMatrix4 = GLKMatrix4MakeTranslation(0.0, 0.0, -6.0)
//        //modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, _rotMatrix);
//        //let rotation: GLKMatrix4 = GLKMatrix4MakeWithQuaternion(quat)
//        //modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, rotation)
//        
//       
//        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, self.rotMatrix);
////        self.effect.transform.modelviewMatrix = modelViewMatrix
//        self.shader.modelViewMatrix = modelViewMatrix
//        self.shader.modelViewMatrix = GLKMatrix4Identity


    }
    
    func projectOntoSurface(touchPoint: GLKVector3) -> GLKVector3 {
        var radius: Float = Float(self.view.bounds.size.width / 3)
        var center: GLKVector3 = GLKVector3Make(Float(self.view.bounds.size.width / 2), Float(self.view.bounds.size.height / 2), 0)
        var P: GLKVector3 = GLKVector3Subtract(touchPoint, center)
        // Flip the y-axis because pixel coords increase toward the bottom.
        P = GLKVector3Make(P.x, P.y * -1, P.z)
        var radius2: Float = radius * radius
        var length2: Float = P.x * P.x + P.y * P.y
        if length2 <= radius2 {
            P = GLKVector3Make(P.x, P.y, sqrt(radius2 - length2))
        }
        else {
            /*
             P.x *= radius / sqrt(length2);
             P.y *= radius / sqrt(length2);
             P.z = 0;
             */
            P = GLKVector3Make(P.x, P.y, radius2 / (2.0 * sqrt(length2)))
            var length: Float = sqrt(length2 + P.z * P.z)
            P = GLKVector3DivideScalar(P, length)
        }
        return GLKVector3Normalize(P)
    }
    
    
    
    func computeIncremental() {
        var axis: GLKVector3 = GLKVector3CrossProduct(anchor_position, current_position)
        var dot: Float = GLKVector3DotProduct(anchor_position, current_position)
        var angle: Float = acosf(dot)
        var Q_rot: GLKQuaternion = GLKQuaternionMakeWithAngleAndVector3Axis(angle * 2, axis)
        Q_rot = GLKQuaternionNormalize(Q_rot)
        // TODO: Do something with Q_rot...
        self.quat = GLKQuaternionMultiply(Q_rot, quatStart)
    }
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        var touch: UITouch = touches.first!
//        var location: CGPoint = touch.locationInView(self.view!)
//        self.anchor_position = GLKVector3Make(Float(location.x), Float(location.y), 0)
//        self.anchor_position = self.projectOntoSurface(anchor_position)
//        self.current_position = anchor_position
//        self.quatStart = quat
//    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        var touch: UITouch = touches.first!
                var location: CGPoint = touch.locationInView(self.view!)
                var lastLoc: CGPoint = touch.previousLocationInView(self.view!)
                var diff: CGPoint = CGPointMake(lastLoc.x - location.x, lastLoc.y - location.y)
                var rotX: Float = -1 * GLKMathDegreesToRadians(Float(diff.y / 2.0))
                var rotY: Float = -1 * GLKMathDegreesToRadians(Float(diff.x / 2.0))

        
        
        square.rotationX = Float(square.rotationX) + Float(diff.x / 20)
        square.rotationY = Float(square.rotationY) + Float(diff.y / 20)


        
        
//        var xAxis :GLKVector3  = GLKVector3Make(1, 0, 0);
//        self.rotMatrix = GLKMatrix4Rotate(self.rotMatrix, rotX, xAxis.x, xAxis.y, xAxis.z);
//        var yAxis : GLKVector3 = GLKVector3Make(0, 1, 0);
//        self.rotMatrix = GLKMatrix4Rotate(self.rotMatrix, rotY, yAxis.x, yAxis.y, yAxis.z);
//
//    
        
//        var touch: UITouch = touches.first!
//        var location: CGPoint = touch.locationInView(self.view!)
//        var lastLoc: CGPoint = touch.previousLocationInView(self.view!)
//        var diff: CGPoint = CGPointMake(lastLoc.x - location.x, lastLoc.y - location.y)
//        var rotX: Float = -1 * GLKMathDegreesToRadians(Float(diff.y / 2.0))
//        var rotY: Float = -1 * GLKMathDegreesToRadians(Float(diff.x / 2.0))
//        var isInvertible: Bool = true
//        let xAxis: GLKVector3 = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(rotMatrix, &isInvertible), GLKVector3Make(1, 0, 0))
//        self.rotMatrix = GLKMatrix4Rotate(rotMatrix, rotX, xAxis.x, xAxis.y, xAxis.z)
//        var yAxis: GLKVector3 = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(rotMatrix, &isInvertible), GLKVector3Make(0, 1, 0))
//        self.rotMatrix = GLKMatrix4Rotate(rotMatrix, rotY, yAxis.x, yAxis.y, yAxis.z)
//        self.current_position = GLKVector3Make(Float(location.x), Float(location.y), 0)
//        self.current_position = self.projectOntoSurface(current_position)
//        self.computeIncremental()
    }
    
    func doubleTap(tap: UITapGestureRecognizer) {
        self.slerping = true
        self.slerpCur = 0
        self.slerpMax = 1.0
        self.slerpStart = quat
        self.slerpEnd = GLKQuaternionMake(0, 0, 0, 1)
    }
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        
        
            loadingIndicator.center = view.center
            loadingIndicator.startAnimating()
            view.addSubview(loadingIndicator)
            
            
            
        loadingIndicator.hidesWhenStopped = true
        setUpSwipeBack()


        readFileFromServer(self)

        setupGLcontext()
        setupGLupdater()
        setupScene()
    }
    
    
    func readFileFromServer(dpCtrl : DisplayPOintsViewController){
        
        
        let url = NSURL(string:"http://dhlabsrv4.epfl.ch/wtm/get.php?f=venezia-gesuati&s=6000000")!
//        HttpDownloader.loadFileAsync(url, completion:{(path:String, error:NSError!) in
//            print("pdf downloaded to: \(path)")
//        })
        Downloader.load(url, DCtrl: dpCtrl )
        
       
    
    }
    
    func setUpSwipeBack() -> (){
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        
        rightSwipe.direction = .Right
        
        
        self.view.addGestureRecognizer(rightSwipe)
        
        
        
    }
    func handleSwipe(sender:UISwipeGestureRecognizer){
        performSegueWithIdentifier("segueDisplayToMain", sender: nil)
        
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        
        glClearColor(1.0, 1.0, 1.0, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        let viewMatrix : GLKMatrix4 = GLKMatrix4MakeTranslation(0, -1, -5)
        self.square.renderWithParentMoelViewMatrix(viewMatrix)


        
    }
    
}

extension DisplayPOintsViewController {
    
    func setupGLcontext() {
        glkView = self.view as! GLKView
        glkView.context = EAGLContext(API: .OpenGLES2)
        EAGLContext.setCurrentContext(glkView.context)
    }
    
    func resetVertices(){
        vertices.removeAll()
    }
    
    func setupGLupdater() {
        self.glkUpdater = GLKUpdater(glkViewController: self)
        self.delegate = self.glkUpdater
    }
    
    func setupShader() {
        self.shader = BaseEffect(vertexShader: "SimpleVertexShader.glsl", fragmentShader: "SimpleFragmentShader.glsl")
    }
    
    func setupScene() {
        self.shader = BaseEffect(vertexShader: "SimpleVertexShader.glsl", fragmentShader: "SimpleFragmentShader.glsl")
        
        self.shader.projectionMatrix = GLKMatrix4MakePerspective(
            GLKMathDegreesToRadians(85.0),
            GLfloat(self.view.bounds.size.width / self.view.bounds.size.height),
            1,
            150)
        
        self.square = Square(shader: self.shader, vertex: vertices)
        self.square.position = GLKVector3(v: (0.0, -0.0, 0))
        
    }
    
    
    func setupVertexBuffer() {
        glGenBuffers(GLsizei(1), &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        let count = vertices.count
        let size =  sizeof(Vertex)
        glBufferData(GLenum(GL_ARRAY_BUFFER), count * size, vertices, GLenum(GL_STATIC_DRAW))
        
    }
    
    func BUFFER_OFFSET(n: Int) -> UnsafePointer<Void> {
        let ptr: UnsafePointer<Void> = nil
        return ptr + n
    }
}

class HttpDownloader {
    
    class func loadFileSync(url: NSURL, completion:(path:String, error:NSError!) -> Void) {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        let destinationUrl = documentsUrl.URLByAppendingPathComponent(url.lastPathComponent!)
        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
            print("file already exists [\(destinationUrl.path!)]")
            completion(path: destinationUrl.path!, error:nil)
        } else if let dataFromURL = NSData(contentsOfURL: url){
            if dataFromURL.writeToURL(destinationUrl, atomically: true) {
                print("file saved [\(destinationUrl.path!)]")
                completion(path: destinationUrl.path!, error:nil)
            } else {
                print("error saving file")
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(path: destinationUrl.path!, error:error)
            }
        } else {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(path: destinationUrl.path!, error:error)
        }
    }
    
    class func loadFileAsync(url: NSURL, completion:(path:String, error:NSError!) -> Void) {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        let destinationUrl = documentsUrl.URLByAppendingPathComponent(url.lastPathComponent!)
        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
            print("file already exists [\(destinationUrl.path!)]")
            completion(path: destinationUrl.path!, error:nil)
        } else {
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if (error == nil) {
                    if let response = response as? NSHTTPURLResponse {
                        print("response=\(response)")
                        if response.statusCode == 200 {
                            if data!.writeToURL(destinationUrl, atomically: true) {
                                print("file saved [\(destinationUrl.path!)]")
                                completion(path: destinationUrl.path!, error:error)
                            } else {
                                print("error saving file")
                                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                                completion(path: destinationUrl.path!, error:error)
                            }
                        }
                    }
                }
                else {
                    print("Failure: \(error!.localizedDescription)");
                    completion(path: destinationUrl.path!, error:error)
                }
            })
            task.resume()
        }
    }
}



class Downloader {
    class func load(URL: NSURL,DCtrl :DisplayPOintsViewController ) {
        
        
        DCtrl.startSpinning()

        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?
            ) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                print("Success: \(statusCode)")
                
                
                //                print("data :  \(data)" )
                
                DCtrl.resetVertices()
                
                // This is your file-variable:
                // data
                
                var count = -1 + (data?.length)!/(3*sizeof(Float) + 4*sizeof(UInt8))
//                count =  100
                var i = -1
                for _ in  1...count{
                i++
                if(i%16 == 0){
                var x : Float = 0
                var y : Float = 0
                var z : Float = 0
                

                data!.getBytes(&x, range: (NSMakeRange(i, sizeofValue(y))))
                data!.getBytes(&y, range: (NSMakeRange(4+i, sizeofValue(y))))
                data!.getBytes(&z, range: (NSMakeRange(8+i, sizeofValue(y))))


                var r : UInt8 = 0
                data!.getBytes(&r, range: (NSMakeRange(12+i, sizeofValue(y))))
//                    print(r)
                var g : UInt8 = 0
                data!.getBytes(&g, range: (NSMakeRange(13+i, sizeofValue(y))))
//                    print(g)
                var b : UInt8 = 0
                data!.getBytes(&b, range: (NSMakeRange(14+i, sizeofValue(y))))
//                    print(b)
                var a : UInt8 = 0
                data!.getBytes(&a, range: (NSMakeRange(15+i, sizeofValue(y))))
                a = max(a,0)
                let vert : Vertex = Vertex(x,y,z,(Float (r))/255.0,(Float(g))/255.0,(Float(b))/255.0,(Float (a))/255.0)
//                print("vert \(i) \(vert)")
                DCtrl.vertices.append(vert)
                }

                }
                
                print("done")
                DCtrl.stopSpinning()

                DCtrl.setupGLcontext()
                DCtrl.setupGLupdater()
                DCtrl.setupScene()
              
                

            }
            else {
                // Failure
                print("Faulure: %@", error!.localizedDescription);
                DCtrl.stopSpinning()
                DCtrl.performSegueWithIdentifier("segueDisplayToMain", sender: nil)

            }
        })
        task.resume()
    }
}
