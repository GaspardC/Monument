package com.epfl.php.testphp;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.ShortBuffer;

import javax.microedition.khronos.opengles.GL10;

/**
 * Created by Gasp on 11/06/16.
 */
public class Point {

    // Our vertices.
    private float vertices[];

    // The order we like to connect them.
    private short[] indices = { 0 };

    // Our vertex buffer.
    private FloatBuffer vertexBuffer;

    // Our index buffer.
    private ShortBuffer indexBuffer;

    private float red,blue,green,alpha ;

    public Point(float x,float y, float z,float red, float green, float blue,float alpha) {

        if(red>1.0f) red = red/256.0f;
        this.red = red;
        if(green>1.0f) green = green/256.0f;
        this.green = green;
        if(blue>1.0f) blue = blue/256.0f;
        this.blue = blue;
        if(alpha>1.0f) alpha = alpha/256.0f;
        this.alpha = alpha;


        // a float is 4 bytes, therefore we multiply the number if
        // vertices with 4.
        vertices = new float[]{
                x, y, z,  // 0, Top Left

        };
        ByteBuffer vbb = ByteBuffer.allocateDirect(vertices.length * 4);
        vbb.order(ByteOrder.nativeOrder());
        vertexBuffer = vbb.asFloatBuffer();
        vertexBuffer.put(vertices);
        vertexBuffer.position(0);

        // short is 2 bytes, therefore we multiply the number if
        // vertices with 2.
        ByteBuffer ibb = ByteBuffer.allocateDirect(indices.length * 2);
        ibb.order(ByteOrder.nativeOrder());
        indexBuffer = ibb.asShortBuffer();
        indexBuffer.put(indices);
        indexBuffer.position(0);
    }

    /**
     * This function draws our square on screen.
     * @param gl
     */
    public void draw(GL10 gl) {
        // Counter-clockwise winding.
        gl.glFrontFace(GL10.GL_CCW);
        // Enable face culling.
        gl.glEnable(GL10.GL_CULL_FACE);
        // What faces to remove with the face culling.
        gl.glCullFace(GL10.GL_BACK);

        // Enabled the vertices buffer for writing and to be used during
        // rendering.
        gl.glEnableClientState(GL10.GL_VERTEX_ARRAY);
        // Specifies the location and data format of an array of vertex
        // coordinates to use when rendering.
        gl.glVertexPointer(3, GL10.GL_FLOAT, 0,
                vertexBuffer);

//        gl.glDrawElements(GL10.GL_TRIANGLES, indices.length,
//                GL10.GL_UNSIGNED_SHORT, indexBuffer);
        gl.glColor4f(red, green, blue, alpha);
        gl.glPointSize(3.0f);
        gl.glDrawElements(GL10.GL_POINTS, indices.length,
                GL10.GL_UNSIGNED_SHORT, indexBuffer);

        // Disable the vertices buffer.
        gl.glDisableClientState(GL10.GL_VERTEX_ARRAY);
        // Disable face culling.
        gl.glDisable(GL10.GL_CULL_FACE);
    }
}
