//
//  LoadObjViewController.swift
//  Monuments
//
//  Created by Gaspard Chevassus on 07/07/2016.
//  Copyright © 2016 Gaspard Chevassus. All rights reserved.
//

import UIKit

class LoadObjViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSwipeBack()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setUpSwipeBack() -> (){
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        
        rightSwipe.direction = .Right
        

        self.view.addGestureRecognizer(rightSwipe)
        
    
        
    }
    func handleSwipe(sender:UISwipeGestureRecognizer){
        performSegueWithIdentifier("segueLoadToMain", sender: nil)
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
