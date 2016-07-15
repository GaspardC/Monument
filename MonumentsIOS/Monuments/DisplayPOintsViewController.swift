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
    
    
    
    
    
    var slerpStart:GLKQuaternion! = GLKQuaternion()
    var slerpEnd: GLKQuaternion! = GLKQuaternion()
    //    var effect:GLKBaseEffect!
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    var vertexBuffer : GLuint = 0
    var indexBuffer: GLuint = 0
    var shader : BaseEffect!
    
    var vertices : [Vertex] = [
        Vertex( -2.5, -0.0, -1.0, 1.0, 0.0, 0.0, 0.0)
        
        
    ]
    
    let indices : [GLubyte] = [
        0, 1, 2,
        2, 3, 0
    ]
    
    
    
    
    
    
    @IBAction func startSpinning() {
        loadingIndicator.startAnimating()
    }
    
    @IBAction func stopSpinning() {
        
        
        loadingIndicator.stopAnimating()
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.effect = GLKBaseEffect()
        
        loadingIndicator.hidesWhenStopped = true
        //        setUpSwipeBack()
        
        
        readFileFromServer(self)
        
        setupGLcontext()
        setupGLupdater()
        setupShader()
        setupVertexBuffer()
    }
    
    
    func readFileFromServer(dpCtrl : DisplayPOintsViewController){
        
        
        let url = NSURL(string:"http://dhlabsrv4.epfl.ch/wtm/get.php?f=venezia-gesuati&s=600000")!
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
        
        
        // shader.begin()
        shader.prepareToDraw()
        //        effect.prepareToDraw()
        
        glDisable(GLenum(GL_CULL_FACE))
        glEnableVertexAttribArray(VertexAttributes.Position.rawValue)
        glVertexAttribPointer(
            VertexAttributes.Position.rawValue,
            3,
            GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),
            GLsizei(sizeof(Vertex)), BUFFER_OFFSET(0))
        
        
        glEnableVertexAttribArray(VertexAttributes.Color.rawValue)
        glVertexAttribPointer(
            VertexAttributes.Color.rawValue,
            4,
            GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),
            GLsizei(sizeof(Vertex)), BUFFER_OFFSET(3 * sizeof(GLfloat))) // x, y, z | r, g, b, a :: offset is 3*sizeof(GLfloat)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        //        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(vertices.count))
        //(GLenum(GL_POINTS), GLsizei(indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        
        glDisableVertexAttribArray(VertexAttributes.Position.rawValue)
        glClearColor(1.0, 1.0, 1.0, 1.0)
        
        
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
    
    func setupVertexBuffer() {
        glGenBuffers(GLsizei(1), &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        let count = vertices.count
        let size =  sizeof(Vertex)
        glBufferData(GLenum(GL_ARRAY_BUFFER), count * size, vertices, GLenum(GL_STATIC_DRAW))
        
        //        glGenBuffers(GLsizei(1), &indexBuffer)
        //        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        //        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indices.count * sizeof(GLubyte), indices, GLenum(GL_STATIC_DRAW))
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
                        //
                        //                print(x)
                        //                print(y)
                        //                print(z)
                        
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
                DCtrl.setupShader()
                DCtrl.setupVertexBuffer()
                
                // the number of elements:
                //                let count = data!.length / sizeof(UInt32)
                //
                //                // create array of appropriate length:
                //                var array = [UInt32](count: count, repeatedValue: 0)
                //                
                //                // copy bytes into array
                //                data!.getBytes(&array, length:count * sizeof(UInt32))
                //                
                //                print(array)
                //                // Output: [32, 4, 123, 4, 5, 2]
                //                
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
