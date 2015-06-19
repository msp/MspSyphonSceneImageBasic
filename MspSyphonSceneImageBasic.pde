// based on chSK_scene_image_basic in Making Things See 
// but hacked to include a Syphon server to publish to VDMX

import processing.opengl.*;
import SimpleOpenNI.*;
import codeanticode.syphon.*;

SyphonServer server;
SyphonServer server2;
SimpleOpenNI  kinect;
PGraphics VDMXCanvas;
PGraphics VDMXCanvas2;

int[] userMap;

PImage rgbImage;
void setup() {
  size(640, 480, P3D);
  VDMXCanvas   = createGraphics(this.g.width, this.g.height, P3D);
  VDMXCanvas2  = createGraphics(this.g.width, this.g.height, P3D);

  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  kinect.enableRGB();
  
  // Create syhpon server to send frames out.
  server  = new SyphonServer(this, "Processing Syphon");
  server2 = new SyphonServer(this, "Processing Syphon 2");
}

void draw() {
  background(0);
  kinect.update();
  
  detectAndColourUsers();  
  sendRGBCameraToVDMX(); 
  sendBuiltInCanvasToVDMX();
  image(VDMXCanvas, 0, height/2);
}

void detectAndColourUsers() {
  // detect any users
  int[] userList = kinect.getUsers();  
  //println("users: "+userList.length);
  
  for(int i=0;i<userList.length;i++) {
    loadPixels();
    
    userMap = kinect.userMap();    
    // println("userMap: "+userMap.length);
    
    for (int j = 0; j < userMap.length; j++) {
      // if the current pixel is on a user
      if (userMap[j] != 0) {
        // make it green        
        pixels[j] = color(0, 255, 0);        
      }
      
      // display the changed pixel array
      updatePixels();        
    }    
  }
}

void sendRGBCameraToVDMX() {
  VDMXCanvas2.beginDraw();
  VDMXCanvas2.image(kinect.rgbImage(), 0, 0);
  VDMXCanvas2.stroke(255);
  VDMXCanvas2.line(20, 20, random(width), random(height));
  VDMXCanvas2.endDraw();
  
  server2.sendImage(VDMXCanvas2);
}

void sendBuiltInCanvasToVDMX() {
//  VDMXCanvas.beginDraw();
//  VDMXCanvas.image(kinect.depthImage(), 0, 0);
//  VDMXCanvas.endDraw();

  VDMXCanvas.loadPixels();
  arrayCopy(this.g.pixels, VDMXCanvas.pixels);
  VDMXCanvas.updatePixels();
 
  server.sendImage(VDMXCanvas);   
}

void onNewUser(int uID) {
  println("tracking "+uID);
}

