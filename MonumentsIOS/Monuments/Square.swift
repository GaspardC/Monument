//
//  Square.swift
//  Model
//
//  Created by burt on 2016. 2. 27..
//  Copyright © 2016년 BurtK. All rights reserved.
//
import GLKit

class Square : Model {
    
    
    let indexList : [GLubyte] = [
        0, 1, 2,
        2, 3, 0
    ]
    
    init(shader: BaseEffect, vertex:[Vertex]) {
        
//        super.init(name: "square", shader: shader, vertices: vertexList, indices: indexList)
        super.init(name: "square", shader: shader, vertices: vertex)
        print("init ", vertex.count)

    }
    
   
    
//    override func updateWithDelta(dt: NSTimeInterval) {
//        let secsPerMove = 2.0
//        self.position = GLKVector3Make(
//            Float(sin(CACurrentMediaTime() * 2 * M_PI / secsPerMove)),
//            self.position.y,
//            self.position.z)
//    }
}
